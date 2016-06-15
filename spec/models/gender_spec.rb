require 'spec_helper'

describe Gender do
  it "has many users" do
    gender = build(:gender)
    user = build(:user, gender: gender)
    expect(user.gender.name).to eq(gender.name)
  end
end
