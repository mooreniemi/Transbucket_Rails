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
      form.save
      saved_pin = form.model
      pin.pin_images.each do |pin_image|
        image = PinImage.find_by!(caption: pin_image.caption)
        expect(image.pin).to eq(saved_pin)
      end

      expect(Surgeon.where(email: pin.surgeon.email)).to exist
      expect(Procedure.where(name: pin.procedure.name)).to exist
    end

    context "when pin already exists" do
      let!(:pin) { create(:pin, :with_surgeon_and_procedure, :real_pin_images) }
      let!(:form) { PinForm.new(pin) }

      shared_examples "delete nested" do
        it "deletes a nested model" do
          id_to_delete = pin.pin_images[0].id
          attrs = pin.attributes
          attrs["pin_images"] = pin.pin_images.map(&:attributes)
          attrs["pin_images"][0]["_destroy"] = "1"
          expect(form.validate(attrs)).to be true
          expect(form.errors.messages).to be_empty
          form.save
          expect(PinImage.where(id: id_to_delete)).not_to exist
        end
      end

      include_examples "delete nested"

      context "with broken images" do
        let!(:pin) { create(:pin, :with_surgeon_and_procedure, :broken_pin_images) }
        let!(:form) { PinForm.new(pin) }

        include_examples "delete nested"

        it "deletes and changes nested models" do
          id_to_delete = pin.pin_images[0].id
          id_to_change = pin.pin_images[1].id
          attrs = pin.attributes
          attrs["pin_images"] = pin.pin_images.map(&:attributes)
          attrs["pin_images"][0]["_destroy"] = "1"
          attrs["pin_images"][1]["caption"] = "new caption"
          expect(form.validate(attrs)).to be true
          expect(form.errors.messages).to be_empty
          form.save
          expect(PinImage.where(id: id_to_delete)).not_to exist
          expect(PinImage.find(id_to_change).caption).to eq("new caption")
        end
      end
    end
  end
end
