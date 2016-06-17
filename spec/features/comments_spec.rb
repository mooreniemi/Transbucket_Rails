require "rails_helper"

RSpec.describe "leaving a comment" do
  let(:pin) { create(:pin, :with_surgeon_and_procedure) }
  let(:comment) { build(:comment) }
  let(:user) { create(:user, :with_confirmation) }

  before(:each) do
    login_as(user, :scope => :user)
  end

  after :each do
    Warden.test_reset!
  end

  it "creates a new comment on a pin" do
    visit "/pins/#{pin.id}"

    within("#new_comment") do
      fill_in "comment[body]", :with => comment.body
      click_button "Submit"
    end

    expect(page).to have_content(comment.body)
  end
end
