require 'spec_helper'

describe Preference do
  it "has many users" do
    preference = build(:preference)
    user = build(:user, preference: preference)
    expect(user.preference).to eq(preference)
  end
end
