require "rails_helper"

describe PinForm do
  let(:pin) { build(:pin) }
  let(:form) { PinForm.new(pin) }

  def confirm_attributes(form, model)
    model.attributes.each do |key, value|
      case key
      when 'updated_at', 'created_at', 'image_file_name',
           'image_content_type', 'image_file_size',
           'image_updated_at', 'username'
        next
      else expect(form.send(key)).to eq(value)
      end
    end
  end

  it "should have all the attributes of a pin" do
    confirm_attributes(form, pin)
  end

  context "with pin_images" do
    it "should have all the attributes of a pin image" do
      confirm_attributes(pin.pin_images.first, pin.pin_images.first)
    end

    it "should create the pin and associate its images when saved" do
      form.save
      saved_pin = form.model
      pin.pin_images.each do |pin_image|
        image = PinImage.find_by(caption: pin_image.caption)
        expect(image.pin).to eq(saved_pin)
      end
    end
  end
end
