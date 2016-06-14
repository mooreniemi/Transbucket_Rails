require 'rails_helper'
require 'faker'

describe "pin creation" do
  include CapybaraHelpers

  let(:user) { create(:user, :with_confirmation) }
  let!(:unknown_surgeon) { create(:surgeon, id: 911, first_name: "Surgeon", last_name: "Unknown") }
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
    let(:new_surgeon) { build(:surgeon) }
    let(:new_procedure) { build(:procedure) }

    def pin_create
      visit '/pins/new'

      add_images(new_images, js: js)
      enter_details(pin_data, js: js)

      expect(page).to have_no_selector("#submit-all[disabled]") if js
    end

    context "with surgeon and procedure initialized" do
      let!(:surgeon) { create(:surgeon) }
      let!(:procedure) { create(:procedure) }

      it "creates a new pin with data and images" do
        self.send(:pin_create)

        select_in_field("pin_surgeon_attributes_id", "#{surgeon.last_name}, #{surgeon.first_name}", js: js)
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
    end
  end

  context "with no js" do
    include_examples "the pin creation process", js: false
  end

  context "with js", :js => true do
    include_examples "the pin creation process", js: true
  end
end
