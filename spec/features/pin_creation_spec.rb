require 'rails_helper'
require 'faker'

describe "pin creation" do
  include CapybaraHelpers

  let(:user) { create(:user, :with_confirmation) }
  let(:new_images) { build_list(:pin_image, 3) }
  let(:pin_data) { gen_pin_data }


  before :each do
    login_as(user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  shared_examples "the pin creation process" do |opts = {}|
    # rspec-core 3.3's include_examples passes options as a positional Hash
    # (module_exec(*args, &shared_block)), which relied on Ruby's pre-3.0
    # implicit hash-to-kwargs conversion to land in a `|js: false|` parameter.
    # Ruby 3 removed that conversion, so this must destructure explicitly.
    let(:js) { opts.fetch(:js, false) }
    let(:new_surgeon) { build(:surgeon) }
    let(:new_procedure) { build(:procedure) }

    def pin_create
      visit '/pins/new'

      add_images(new_images, js: js)
      enter_details(pin_data, js: js)

      expect(page).to have_no_selector("#submit-all[disabled]") if js
    end

    context "with no surgeons or procedures" do
      it "keeps the complication tag editor hidden until the author says they had complications" do
        visit '/pins/new'

        if js
          expect(page).to have_no_field('pin_complication_input')
          expect(page).to have_no_text(I18n.t('public.form.complications_help'))

          within('.complication-toggle') { choose I18n.t('public.form.complications_yes') }

          expect(page).to have_field('pin_complication_input', disabled: false)
          expect(page).to have_no_selector('.complication-tag-editor .input-group-addon')
          expect(page).to have_text(I18n.t('public.form.complications_help'))
        else
          # Without JS/CSS the editor is in the page, but disabled until "Yes" is chosen.
          expect(page).to have_field('pin_complication_input', disabled: true)
          expect(page).to have_no_selector('.complication-tag-editor .input-group-addon')
        end
      end

      it "returns errors upon submission" do
        self.send(:pin_create)
        click_button "Submit Now"

        expect(find("#error_explanation")).to have_content("errors")
      end
    end

    context "with surgeon and procedure initialized" do
      let!(:surgeon) { create(:surgeon) }
      let!(:procedure) { create(:procedure) }

      it "accepts comma-separated complication tags" do
        visit '/pins/new'
        find('input[data-complications-toggle][value="1"]').click if js

        if js
          fill_in 'pin_complication_input', with: 'hematoma, fistula,'
          expect(page).to have_selector('.complication-chip', count: 2)
        else
          expect(page).to have_field('pin_complication_input', disabled: true)
        end
      end

      it "creates a new pin with data and images" do
        self.send(:pin_create)

        select_in_field("pin_surgeon_attributes_id", surgeon.to_s, js: js)
        select_in_field("pin_procedure_attributes_id", procedure.name, js: js)

        click_button "Submit Now"

        check_surgeon_and_procedure(surgeon, procedure)
        expect(page).to have_content("Please respect pronouns")
        check_pin_data(pin_data)
        check_photos(new_images)
      end

      it "creates a pin, adding a new surgeon and procedure" do
        self.send(:pin_create)
        add_surgeon(new_surgeon, js: js)
        add_procedure(new_procedure, js: js)

        click_button "Submit Now"

        expect(page).to have_content("Please respect pronouns")
        check_surgeon_and_procedure(new_surgeon, new_procedure)
        check_pin_data(pin_data)
        check_photos(new_images)
      end

      it "creates a pin, selecting a surgeon but duplicating a procedure" do
        self.send(:pin_create)
        select_in_field("pin_surgeon_attributes_id", surgeon.to_s, js: js)
        add_procedure(procedure, js: js)

        click_button "Submit Now"

        expect(find("#error_explanation")).to have_content("Procedure name has already been taken")
      end
    end
  end

  context "with no js" do
    include_examples "the pin creation process", js: false
  end

  context "with js", :js => true do
    include_examples "the pin creation process", js: true
  end

  context 'with an oversized phone photo', :js => true do
    let!(:surgeon) { create(:surgeon) }
    let!(:procedure) { create(:procedure) }

    it 'resizes the photo before uploading it' do
      photo = Tempfile.new(['phone-photo', '.jpg'])
      photo.binmode
      photo.write(File.binread(Rails.root.join('spec/fixtures/cat.jpg')))
      photo.truncate(2.megabytes)
      photo.rewind

      visit '/pins/new'
      find('.dz-hidden-input', visible: false)
      page.execute_script("$('.dz-hidden-input').attr('id', 'dz-file-input')")
      attach_file('dz-file-input', photo.path, visible: false)

      expect(page).to have_selector('.dz-image-preview img[alt]:not([alt=\'\'])')
      resized_size = page.evaluate_script("$('.form-inline')[0].dropzone.files[0].size")
      expect(resized_size).to be <= PinImage::UPLOAD_SIZE_LIMIT - 64.kilobytes

      enter_details(gen_pin_data, js: true)
      select_in_field('pin_surgeon_attributes_id', surgeon.to_s, js: true)
      select_in_field('pin_procedure_attributes_id', procedure.name, js: true)
      click_button 'Submit Now'

      expect(page).to have_content('Please respect pronouns')
      expect(Pin.last.pin_images.first.photo_file_size).to be <= PinImage::UPLOAD_SIZE_LIMIT
    ensure
      photo.close!
    end
  end
end
