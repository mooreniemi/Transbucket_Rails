require 'spec_helper'

describe PinCreatorService, '#santize_name' do
  it "should sanitize a name" do
    service = PinCreatorService.new({},'user')
    expect(service.send(:sanitize_name, 'dippy-dot, md')).to eq('dippy-dot')
    expect(service.send(:sanitize_name, 'Dr. dippy-dot, MD')).to eq('dippy-dot')
    expect(service.send(:sanitize_name, 'dippy-dot md')).to eq('dippy-dot')
    expect(service.send(:sanitize_name, 'dr dippy-dot m.d.')).to eq('dippy-dot')
  end
end