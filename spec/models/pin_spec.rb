#spec/models/pin_spec.rb
require 'spec_helper'

describe Pin do
  it "has a valid factory" do
    expect(create(:pin)).to be_valid
  end
  it "is invalid without a surgeon" do
    expect(build(:pin, surgeon: nil)).to_not be_valid
  end
  it "is invalid without a user_id" do
    expect(build(:pin, user_id: nil)).to_not be_valid
  end
  it "is invalid without a procedure" do
    expect(build(:pin, procedure: nil)).to_not be_valid
  end
  it "is published as its initial state" do
    expect(build(:pin).state).to eq("published")
  end
end
