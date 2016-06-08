require "rails_helper"
require "faker"

describe "pin updating" do
  include CapybaraHelpers

  let(:user) { create(:user, :with_confirmation) }
  let(:pin) { create(:pin, :with_surgeon_and_procedure, :real_pin_images) }
  let(:pin_data) { { :cost => rand(999),
                     :experience => Faker::Lorem.sentences(3).join(" ")
                   } }
  let(:new_images) { build_list(:pin_image, 2) }

  before :each do
    login_as(user, :scope => :user)

    ensure_on "/pins/#{pin.id}/edit"
  end

  after :each do
    Warden.test_reset!
  end

  shared_examples "pin updating" do
    it "updates the pin with new info" do
      self.send(:updater)

      click_button "Submit Now"

      check_pin_data(pin_data)
    end

    it "updates the pin with new info and photos" do
      self.send(:updater)
      self.send(:updater_photos)

      click_button "Submit Now"

      check_pin_data(pin_data)
      check_photos(new_images)
    end
  end

  context "without js" do
    def updater
      enter_details(pin_data)
    end

    def updater_photos
      add_images(new_images)
    end

    include_examples "pin updating"
  end

  context "with js", :js => true do
    def updater
      enter_details(pin_data, js: true)
    end

    def updater_photos
      offset = page.evaluate_script("$('.dz-image-preview').length")
      add_images(new_images, js: true, offset: offset)
    end

    include_examples "pin updating"
  end
end
