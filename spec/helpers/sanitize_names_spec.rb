require 'spec_helper'

describe SanitizeNames do

  let(:surgeon) { Surgeon.new }

  it "can sanitize a surgeons last_name" do
    surgeon.last_name = 'bogart M.D.'
    expect(surgeon.sanitize_last_name).to eq('bogart')
  end

  it "can sanitize an incoming attribute" do
    attrs = attributes_for(:surgeon)
    attrs.extend(SanitizeNames)
    expect(attrs.sanitize_last_name).to be_truthy
  end
end
