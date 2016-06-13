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

  shared_examples "the pin creation process" do |js: false|
    let(:js) { js }

    def pin_create
      visit '/pins/new'

      add_images(new_images, js: js)
      enter_details(pin_data, js: js)

      expect(page).to have_no_selector("#submit-all[disabled]") if js
    end

    context "with no surgeons or procedures defined" do
      it "fails to create a new pin, displaying errors" do
        self.send(:pin_create)

        click_button "Submit Now"

        expect(page).to have_content("Surgeon can't be blank")
        expect(page).to have_content("Procedure can't be blank")
      end

      it "creates a new pin if surgeon and procedure are added" do
        self.send(:pin_create)

        surgeon = build(:surgeon)
        procedure = build(:procedure)
        add_surgeon(surgeon, js: js)
        add_procedure(procedure, js: js)

        click_button "Submit Now"

        check_surgeon_and_procedure(surgeon, procedure)
        check_pin_data(pin_data)
        check_photos(new_images)
      end
    end

    context "with surgeon and procedure initialized" do
      let!(:surgeon) { create(:surgeon) }
      let!(:procedure) { create(:procedure) }

      it "creates a new pin with data and images" do
        self.send(:pin_create)

        click_button "Submit Now"

        check_surgeon_and_procedure(surgeon, procedure)
        expect(page).to have_content("Please respect pronouns")
        check_pin_data(pin_data)
        check_photos(new_images)
      end
    end
  end

  context "with no js" do
    include_examples "the pin creation process", js: false
  end

  context "with js", :js => true do
    include_examples "the pin creation process", js: true
  end
end
