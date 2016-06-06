require 'rails_helper'

describe "the flagging process" do
  let!(:users) { create_list(:user, 4, :with_confirmation) }
  let!(:pin) { create(:pin, :with_comments, :with_surgeon_and_procedure, user_id: users.first.id) }

  before :each do
    allow_any_instance_of(Paperclip::Attachment).to receive(:url).and_return("/assets/register.png")
  end

  after :each do
    Warden.test_reset!
  end

  context "when dealing with own posts" do
    it "should not display the flag for your own pin" do
      login_as(users[0], :scope => :user)

      visit '/pins'
      pin_item = find(".item[data-pin-id='" + pin.id.to_s + "']")

      expect(pin_item).to have_no_selector('a[href="/pins/' + pin.id.to_s + '/flags"]')
    end

    it "should not allow you to flag your own comment" do
      login_as(users[1], :scope => :user)

      visit '/pins/' + pin.id.to_s

      comment_text = "This is my comment: nonce #{rand(9999)}"
      within("#new_comment") do
        fill_in "comment_body", :with => comment_text
      end

      click_button "Submit"

      comment = find('.comment', :text => comment_text)
      expect(comment).to have_no_selector(".fa-flag")
    end
  end

  context "3 users' flags", :js => true do
    it "should unpublish a pin" do
      users[1..-1].each do |user|
        login_as(user, :scope => :user)

        visit '/pins'
        flag_link = find('a[href="/pins/' + pin.id.to_s + '/flags"]')
        flag_link.click
      end

      visit '/pins'

      expect(page).to have_no_selector(".item[data-pin-id='" + pin.id.to_s + "']")
    end

    it "should unpublish a comment" do
      comment_id = pin.comments.first.id
      users[1..-1].each do |user|
        login_as(user, :scope => :user)

        visit '/pins/' + pin.id.to_s
        flag_link = find("#comment-#{comment_id} .fa-flag").find(:xpath, "..")
        flag_link.click
      end

      visit '/pins/' + pin.id.to_s
      expect(page).to have_no_selector("#comment-#{comment_id}")
    end

 end

end
