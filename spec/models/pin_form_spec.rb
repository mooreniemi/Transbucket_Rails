require "rails_helper"

describe PinForm do
  let(:pin) { build(:pin) }

  it "should have all the information from a pin" do
    form = PinForm.new(pin)
    pin.attributes.each do |key, value|
      case key
      when 'updated_at', 'created_at', 'image_file_name',
           'image_content_type', 'image_file_size',
           'image_updated_at', 'username'
        next
      else expect(form.send(key)).to eq(value)
      end
    end
  end
end
