require "rails_helper"

RSpec.describe "commenting", :fake_images => true, :js => true do
  let!(:original_wait) { Capybara.default_max_wait_time }
  let(:pin) { create(:pin, :with_surgeon_and_procedure) }
  let(:comment) { build(:comment) }
  let(:user) { create(:user, :with_confirmation) }

  before(:each) do
    login_as(user, :scope => :user)
    Capybara.default_max_wait_time = 2 * original_wait
  end

  after :each do
    Warden.test_reset!
    Capybara.default_max_wait_time = original_wait
  end

  it "creates a new comment on a pin from the box that is already open" do
    visit "/pins/#{pin.id}"

    within("#commentable") do
      fill_in "comment[body]", :with => comment.body
      click_button "Post"
    end

    expect(page).to have_selector(".comment-list .comment-body", :text => comment.body)
    # The box stays, empty, ready for another comment.
    expect(find("#commentable textarea").value).to eq("")
  end

  it "adds another comment on a thread" do
    visit "/pins/#{pin.id}"

    within("#commentable") do
      fill_in "comment[body]", :with => comment.body
      click_button "Post"
    end

    expect(page).to have_content(comment.body)

    comment_div = find(".comment", :text => comment.body)
    comment_div.click_link "Reply"

    reply = build(:comment)
    new_comment = "##{comment_div[:id]} #new_comment"
    within(new_comment) do
      fill_in "comment[body]", :with => reply.body
      click_button "Post"
    end

    expect(page).not_to have_selector(new_comment)
    expect(page).to have_selector(".comment-body", :text => reply.body)
  end

  context "the comment box" do
    def textarea_height
      page.evaluate_script("document.querySelector('#commentable textarea').getBoundingClientRect().height")
    end

    it "is one line until you tap into it, and folds back if you leave it empty" do
      visit "/pins/#{pin.id}"

      expect(page).to have_css("#commentable textarea[placeholder='#{I18n.t('public.pin.comment_placeholder')}']")
      expect(page).not_to have_button(I18n.t('public.pin.post_comment'))
      collapsed = textarea_height
      top = page.evaluate_script("document.querySelector('#commentable textarea').getBoundingClientRect().top")

      find("#commentable textarea").click

      expect(page).to have_button(I18n.t('public.pin.post_comment'), disabled: true)
      expect(textarea_height).to be > collapsed
      # It grows downwards: the place you tapped does not move.
      expect(page.evaluate_script("document.querySelector('#commentable textarea').getBoundingClientRect().top")).to be_within(1).of(top)

      find(".comments-heading").click
      expect(page).not_to have_button(I18n.t('public.pin.post_comment'))
    end

    it "only lets you post once there is something to post" do
      visit "/pins/#{pin.id}"
      find("#commentable textarea").click
      expect(page).to have_button(I18n.t('public.pin.post_comment'), disabled: true)

      find("#commentable textarea").send_keys("   ")
      expect(page).to have_button(I18n.t('public.pin.post_comment'), disabled: true)

      find("#commentable textarea").send_keys("Hello")
      expect(page).to have_button(I18n.t('public.pin.post_comment'), disabled: false)
    end

    it "keeps Return as a new line and posts with Ctrl+Return, then folds back to one line" do
      visit "/pins/#{pin.id}"
      box = find("#commentable textarea")
      box.click
      box.send_keys("First line", :enter, "Second line")
      expect(page).to have_no_css(".comment-list .comment")
      expect(box.value).to eq("First line\nSecond line")

      box.send_keys([:control, :enter])

      expect(page).to have_css(".comment-list .comment-body", text: "First line")
      expect(find("#commentable textarea").value).to eq("")
      expect(page).not_to have_button(I18n.t('public.pin.post_comment'))
    end

    context "with fragment caching on, as on staging and production" do
      around do |example|
        caching, store = ActionController::Base.perform_caching, ActionController::Base.cache_store
        ActionController::Base.perform_caching = true
        ActionController::Base.cache_store = ActiveSupport::Cache::MemoryStore.new
        begin
          example.run
        ensure
          ActionController::Base.perform_caching = caching
          ActionController::Base.cache_store = store
        end
      end

      def indent_of(selector)
        page.evaluate_script("document.querySelector(#{selector.to_json}).getBoundingClientRect().left")
      end

      it "nests a reply under its parent straight away, and still after a reload" do
        parent = create(:comment, commentable: pin, user: user, body: "The parent comment")
        visit "/pins/#{pin.id}"
        # Render (and cache) the parent before the reply exists.
        expect(page).to have_css("#comment-#{parent.id} .comment-body", text: "The parent comment")

        find("#comment-#{parent.id}").click_link "Reply"
        within("#comment-#{parent.id} .reply-target") do
          fill_in "comment[body]", :with => "A nested reply"
          click_button "Post"
        end

        reply_body = "#comment-#{parent.id} .comment-replies .comment-body"
        expect(page).to have_css(reply_body, text: "A nested reply")
        expect(page).not_to have_css("#comment-#{parent.id} .reply-target textarea")
        expect(indent_of(reply_body)).to be > indent_of("#comment-#{parent.id} > .comment-body")

        visit "/pins/#{pin.id}"

        expect(page).to have_css(reply_body, text: "A nested reply")
        expect(page).to have_css(".comment-list > .comment", count: 1)
        expect(indent_of(reply_body)).to be > indent_of("#comment-#{parent.id} > .comment-body")
      end
    end

    context "with fragment caching on, for different viewers" do
      around do |example|
        caching, store = ActionController::Base.perform_caching, ActionController::Base.cache_store
        ActionController::Base.perform_caching = true
        ActionController::Base.cache_store = ActiveSupport::Cache::MemoryStore.new
        begin
          example.run
        ensure
          ActionController::Base.perform_caching = caching
          ActionController::Base.cache_store = store
        end
      end

      it "shows delete only to the author and Report only to everyone else" do
        mine = create(:comment, commentable: pin, user: user, body: "Written by me")

        visit "/pins/#{pin.id}"
        within("#comment-#{mine.id}") do
          expect(page).to have_css("a.close")
          expect(page).not_to have_css(".flag-comment")
        end

        other = create(:user, :with_confirmation)
        Warden.test_reset!
        login_as(other, :scope => :user)
        visit "/pins/#{pin.id}"

        within("#comment-#{mine.id}") do
          expect(page).not_to have_css("a.close")
          expect(page).to have_css(".flag-comment")
        end
      end
    end

    it "lets you reply to a comment you have only just posted" do
      visit "/pins/#{pin.id}"
      within("#commentable") do
        fill_in "comment[body]", :with => "Just posted"
        click_button "Post"
      end
      fresh = find(".comment-list .comment", text: "Just posted")

      fresh.click_link "Reply"
      within("##{fresh[:id]} .reply-target") do
        fill_in "comment[body]", :with => "Replying to it"
        click_button "Post"
      end

      expect(page).to have_css("##{fresh[:id]} .comment-body", text: "Replying to it")
      expect(Comment.find_by(body: "Replying to it").parent_id).to eq(fresh[:id].sub("comment-", "").to_i)
    end

    it "opens a reply box with the cursor already in it" do
      create(:comment, commentable: pin, user: user, body: "Reply to me")
      visit "/pins/#{pin.id}"

      find(".comment", text: "Reply to me").click_link "Reply"

      expect(page).to have_css(".comment .reply-target textarea")
      expect(page.evaluate_script("document.activeElement === document.querySelector('.comment .reply-target textarea')")).to be(true)
      expect(page).to have_button(I18n.t('public.pin.post_comment'), disabled: true)
    end
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
