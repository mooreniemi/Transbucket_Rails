require "rails_helper"

RSpec.describe "user settings" do
  let!(:genders) { create_list(:gender, 5) }
  let(:user) { create(:user, :with_confirmation, gender: genders.last) }

  before(:each) do
    login_as(user, :scope => :user)
    visit '/users/edit'
  end

  after :each do
    Warden.test_reset!
  end

  it "shows the correct user info and gender" do
    expect(find("#user_name").value).to eq(user.name)
    expect(find("#user_username").value).to eq(user.username)
    expect(find("#user_gender_id").value.to_i).to eq(user.gender.id)
    expect(find("#user_email").value).to eq(user.email)
    expect(find("#user_password").value).to eq(nil)
  end
end
