require 'rails_helper'

# Discussion cards in the home feed, on a phone: they arrive with infinite
# scroll, the whole card opens the thread at that comment, Reply opens the
# reply box there, and the footer actions work without leaving the feed.
RSpec.describe 'discussions in the home feed on a phone', js: true, fake_images: true do
  let!(:user) { create(:user, :with_confirmation) }
  let(:author) { create(:user, :with_confirmation) }
  let(:procedure) { create(:procedure, name: 'double incision') }

  before do
    Rails.cache.clear
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  after do
    page.current_window.resize_to(1400, 1000)
    Warden.test_reset!
  end

  def scroll_until(selector, count)
    8.times do
      break if page.has_css?(selector, count: count, wait: 1)
      page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
    end
  end

  it 'loads discussion cards from later pages as you scroll' do
    allow(Pin).to receive(:per_page).and_return(2)
    create_list(:pin, 4, user: user)
    older = Comment.create!(commentable: procedure, user: author, body: 'An older discussion on page three', created_at: 30.days.ago)

    visit '/en/pins'
    scroll_until('#pins .item', 5)

    expect(page).to have_css("#pins .feed-discussion[data-comment-id='#{older.id}']")
    expect(page).to have_css('#pins .item', count: 5)
  end

  it 'opens the thread at that comment when you tap anywhere on the card' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'Tap me anywhere')

    visit '/en/pins'
    # The card itself: the stretched topic link takes the tap, as on a phone.
    find(".feed-discussion[data-comment-id='#{comment.id}']").click

    expect(page).to have_current_path(procedure_path(procedure, locale: 'en'), ignore_query: true)
    expect(page.evaluate_script('window.location.hash')).to eq("#comment-#{comment.id}")
    expect(page).to have_css("#comment-#{comment.id}", text: 'Tap me anywhere')
  end

  it 'opens the reply box under that comment when you tap Reply' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'Reply to me')

    visit '/en/pins'
    find(".feed-discussion[data-comment-id='#{comment.id}'] a.feed-discussion-reply").click

    expect(page).to have_css("#comment-#{comment.id} .reply-target textarea")
  end

  it 'opens the reply box on a surgeon thread too, and the reply posts' do
    surgeon = create(:surgeon)
    comment = Comment.create!(commentable: surgeon, user: author, body: 'Surgeon thread')

    visit '/en/pins'
    find(".feed-discussion[data-comment-id='#{comment.id}'] a.feed-discussion-reply").click
    within("#comment-#{comment.id} .reply-target") do
      find('textarea').fill_in(with: 'A reply on the surgeon page')
      find('[type=submit]').click
    end

    expect(page).to have_css("#comment-#{comment.id} .comment-replies", text: 'A reply on the surgeon page')
    expect(Comment.find_by(body: 'A reply on the surgeon page')).to have_attributes(commentable_type: 'Surgeon', commentable_id: surgeon.id, parent_id: comment.id)
  end

  it 'lets you report someone else\'s post without leaving the feed' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'Report me')

    visit '/en/pins'
    accept_confirm { find(".feed-discussion[data-comment-id='#{comment.id}'] a.flag-comment").click }

    expect(page).to have_css(".feed-discussion[data-comment-id='#{comment.id}'] .flag-reported")
    expect(page).to have_current_path('/en/pins')
  end

  it 'removes your own post from the feed when you delete it' do
    comment = Comment.create!(commentable: procedure, user: user, body: 'Delete me')

    visit '/en/pins'
    accept_confirm { find(".feed-discussion[data-comment-id='#{comment.id}'] a.feed-discussion-delete").click }

    expect(page).not_to have_css(".feed-discussion[data-comment-id='#{comment.id}']", visible: true)
    expect(Comment.exists?(comment.id)).to eq(false)
  end

  it 'keeps every action big enough to tap and the page no wider than the phone' do
    comment = Comment.create!(commentable: procedure, user: author, body: 'Sizes')

    visit '/en/pins'
    card = ".feed-discussion[data-comment-id='#{comment.id}']"
    heights = page.evaluate_script(<<~JS)
      ['a.feed-discussion-reply', 'a.flag-comment'].map(function(sel) {
        return Math.round(document.querySelector("#{card} " + sel).getBoundingClientRect().height);
      })
    JS

    expect(heights).to all(be >= 44)
    # No sideways scrolling: the page is no wider than the browser's viewport.
    # (Desktop Chrome won't shrink its window below about 500px, so compare
    # against the real viewport rather than 390.)
    expect(page.evaluate_script('document.documentElement.scrollWidth')).to be <= page.evaluate_script('window.innerWidth')
  end
end
