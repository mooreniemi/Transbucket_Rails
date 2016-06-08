require "rails_helper"

describe PinForm do
  let(:pin) { build(:pin, :with_surgeon_and_procedure, :real_pin_image_attrs) }
  let(:form) { PinForm.new(pin) }

  it "should have all the attributes of a pin" do
    confirm_attributes(form, pin)
  end

  context "when starting from scratch" do
    let (:form) { PinForm.new(Pin.new) }

    it "should require a user" do
      form.validate({})
      expect(form.errors[:user_id]).to include("can't be blank")
    end

    it "should require a surgeon" do
      form.validate({})
      expect(form.errors[:surgeon_id]).to include("can't be blank")
    end

    it "should require a procedure" do
      form.validate({})
      expect(form.errors[:procedure_id]).to include("can't be blank")
    end

    it "should be able to validate a real pin" do
      form.validate(pin.attributes)
      expect(form.errors.messages).to be_empty
    end
  end

  context "with pin_images" do
    it "should have all the attributes on its pin_images" do
      confirm_attributes(form.pin_images.first, pin.pin_images.first)
    end
  end

  context "with nested models" do
    it "should create the pin and its nested models when saved" do
      allow_any_instance_of(Paperclip::Storage::Filesystem).to receive(:copy_to_local_file).and_return(nil)
      form.save
      saved_pin = form.model
      pin.pin_images.each do |pin_image|
        image = PinImage.find_by!(caption: pin_image.caption)
        expect(image.pin).to eq(saved_pin)
      end

      expect(Surgeon.where(email: pin.surgeon.email)).to exist
      expect(Procedure.where(name: pin.procedure.name)).to exist
    end
  end
end
