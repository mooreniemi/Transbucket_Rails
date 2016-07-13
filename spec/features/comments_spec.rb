require "rails_helper"

RSpec.describe "commenting", :fake_images => true, :js => true do
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

    click_link "add thread"
    within("#new_comment") do
      fill_in "comment[body]", :with => comment.body
      click_button "Submit"
    end

    expect(page).to have_selector(".panel-body", :text => comment.body)
  end

  it "adds another comment on a thread" do
    visit "/pins/#{pin.id}"

    click_link "add thread"
    within("#new_comment") do
      fill_in "comment[body]", :with => comment.body
      click_button "Submit"
    end

    expect(page).to have_content(comment.body)

    comment_div = find(".comment", :text => comment.body)
    comment_div.click_link "reply"

    reply = build(:comment)
    new_comment = "##{comment_div[:id]} #new_comment"
    within(new_comment) do
      fill_in "comment[body]", :with => reply.body
      click_button "Submit"
    end

    expect(page).not_to have_selector(new_comment)
    expect(page).to have_selector(".panel-body", :text => reply.body)
  end

  context "deletion" do
    let!(:comment) { create(:comment, user: user, commentable: pin) }

    before(:each) do
      visit "/pins/#{pin.id}"
      expect(page).to have_content(comment.body)
    end

    it "allows users to delete their comments" do
      accept_confirm do
        find("a.close").click
      end

      expect(page).not_to have_content(comment.body)
    end

    it "doesn't delete if confirmation is dismissed" do
      dismiss_confirm do
        find("a.close").click
      end

      expect(page).to have_content(comment.body)
    end
  end
end
