require 'spec_helper'

describe PinUpdaterService, '#santize_last_name' do
  it "can sanitize a surgeon's name" do
    attrs = attributes_for(:surgeon)
    attrs[:last_name] = "dippy-dot M.D."
    pin, user = create(:pin), create(:user)
    params = {
      pin_id: pin.id,
      surgeon_attributes: attrs,
      procedure_attributes: attributes_for(:procedure)
    }
    PinUpdaterService.new(params,user).update
    expect(pin.reload.surgeon.last_name).to eq('dippy-dot')
  end
end
