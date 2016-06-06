require 'rails_helper'

describe PinCreatorService, '#create' do
  let!(:user) { create(:user) }
  let(:pin_params) { attributes_for(:pin).merge!({pin_image_ids: "1"})}
  let(:surgeon_params) { attributes_for(:surgeon) }
  let(:procedure_params) { attributes_for(:procedure) }

  it "can create a new pin" do
    service = PinCreatorService.new(pin_params, user)

    expect{ service.create.save! }.to change{ Pin.count }.from(Pin.count).to(Pin.count + 1)
  end
end
