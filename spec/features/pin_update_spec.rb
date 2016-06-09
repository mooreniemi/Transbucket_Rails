require "rails_helper"
require "faker"

describe "pin updating" do
  include CapybaraHelpers

  let(:user) { create(:user, :with_confirmation) }
  let(:pin) { create(:pin, :with_surgeon_and_procedure, :real_pin_images, user: user) }
  let(:pin_data) { { :cost => rand(999),
                     :experience => Faker::Lorem.sentences(3).join(" ")
                   } }
  let(:new_images) { build_list(:pin_image, 2) }

  before :each do
    login_as(user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  shared_examples "pin updating" do
    it "updates the pin with one less photo and new info" do
      ensure_on "/pins/#{pin.id}/edit"
      self.send(:updater)

      click_button "Submit Now"

      check_pin_data(pin_data)
      expect(page).not_to have_content(pin.pin_images[0].caption)
      check_photos(pin.pin_images[1..-1])
    end

    it "updates the pin with new info and photos" do
      ensure_on "/pins/#{pin.id}/edit"
      self.send(:updater)
      self.send(:updater_photos)

      click_button "Submit Now"

      check_pin_data(pin_data)

      expect(page).not_to have_content(pin.pin_images[0].caption)
      check_photos(pin.pin_images[1..-1] + new_images)
    end
  end

  context "without js" do
    def updater
      enter_details(pin_data)
      pin_image_to_remove = pin.pin_images[0]
      img_to_remove = find("[data-pin-image-id='#{pin_image_to_remove.id}']")
      img_to_remove.check "Remove"
    end

    def updater_photos
      offset = 2
      add_images(new_images, offset: offset)
    end

    include_examples "pin updating"

    context "with broken pin images" do
      let(:pin) { create(:pin, :with_surgeon_and_procedure, :broken_pin_images) }

      include_examples "pin updating"
    end
  end

  context "with js", :js => true do
    def updater
      enter_details(pin_data, js: true)

      pin_image_to_remove = pin.pin_images[0]
      img_to_remove = find(".dz-image-preview[data-pin-image-id='#{pin_image_to_remove.id}']")
      img_to_remove.click_link "Remove file"
    end

    def updater_photos
      offset = page.evaluate_script("$('.dz-image-preview').length")
      expect(offset).to eq(1)
      add_images(new_images, js: true, offset: offset)
    end

    include_examples "pin updating"

    context "with broken pin images" do
      let(:pin) { create(:pin, :with_surgeon_and_procedure, :broken_pin_images) }

      include_examples "pin updating"
    end
  end
end
