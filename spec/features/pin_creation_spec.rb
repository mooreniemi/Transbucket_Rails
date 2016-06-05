require 'rails_helper'

describe "pin creation", :js => true do
  before :each do
    @user = create(:user)
    @user.skip_confirmation!
    @user.save!
    login_as(@user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  it "should create a new pin with data and images" do
    visit '/pins/new'
    expect(page).to have_content 'Procedure'
  end
end
