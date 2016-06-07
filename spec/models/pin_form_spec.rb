require "rails_helper"

describe PinForm do
  let(:pin) { build(:pin, :with_surgeon_and_procedure) }
  let(:form) { PinForm.new(pin) }

  it "should have all the attributes of a pin" do
    confirm_attributes(form, pin)
  end

  context "inside pin_images" do
    it "should have all the attributes of a pin image" do
      confirm_attributes(pin.pin_images.first, pin.pin_images.first)
    end
  end

  context "with nested models" do
    it "should create the pin and nested models when saved" do
      form.save
      saved_pin = form.model
      pin.pin_images.each do |pin_image|
        image = PinImage.find_by(caption: pin_image.caption)
        expect(image.pin).to eq(saved_pin)
      end

      expect(Surgeon.where(email: pin.surgeon.email)).to exist
      expect(Procedure.where(name: pin.procedure.name)).to exist
    end
  end
end
