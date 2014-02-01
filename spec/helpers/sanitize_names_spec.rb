require 'spec_helper'

describe SanitizeNames do

  let(:surgeon) { Surgeon.new }

  it "can sanitize a surgeons last_name" do
    surgeon.last_name = 'bogart M.D.'
    surgeon.sanitize_last_name.should eq('bogart')
  end

  it "can sanitize an incoming attribute" do
    attrs = attributes_for(:surgeon)
    attrs.extend(SanitizeNames)
    attrs.sanitize_last_name.should be_true
  end
end
