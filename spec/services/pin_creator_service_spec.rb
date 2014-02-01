require 'spec_helper'

describe PinCreatorService, '#santize_last_name' do
  it "can sanitize a surgeon's name" do
    attrs = attributes_for(:surgeon)
    attrs[:last_name] = "dippy-dot M.D."
    user = create(:user)
    service = PinCreatorService.new({surgeon_attributes: attrs, procedure_attributes: attributes_for(:procedure)},user)
    pin = service.create
    expect(pin.surgeon.last_name).to eq('dippy-dot')
  end
end

describe PinCreatorService, '#create' do

  it "can create a new pin" do
    user = create(:user)
    pin_params = attributes_for(:pin)

    service = PinCreatorService.new(pin_params, user)

    expect{ service.create.save! }.to change{ Pin.count }.from(Pin.count).to(Pin.count + 1)
  end

  it "can create a new pin with a new surgeon" do
    user = create(:user)
    procedure = create(:procedure)
    pin_params = attributes_for(:pin)
    pin_params.delete(:surgeon_id)

    surgeon_params = attributes_for(:surgeon)

    pin_params.merge!({surgeon_attributes: surgeon_params.keep_if {|k| [:last_name, :first_name, :url].include?(k) }})

    service = PinCreatorService.new(pin_params, user)

    expect{ service.create.save! }.to change{ Surgeon.count }.from(Surgeon.count).to(Surgeon.count + 1)
  end

  it "can create a new pin with a new procedure" do
    user = create(:user)
    surgeon = create(:surgeon)
    pin_params = attributes_for(:pin)

    procedure_params = attributes_for(:procedure)

    pin_params.merge!({procedure_attributes: procedure_params.keep_if {|k| [:name, :gender, :body_type].include?(k) }})

    service = PinCreatorService.new(pin_params, user)

    expect{ service.create.save! }.to change{ Procedure.count }.from(Procedure.count).to(Procedure.count + 1)
  end

end