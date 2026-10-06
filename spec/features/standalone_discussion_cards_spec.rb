require 'rails_helper'

# On a phone a standalone discussion's card opens over the feed, like the
# other discussion cards; its Reply opens with the reply box ready.
RSpec.describe 'standalone discussion cards on a phone', js: true do
  let!(:user) { create(:user, :with_confirmation) }
  let!(:discussion) { create(:discussion, title: 'Recovery questions', body: 'What helped you most?') }

  before do
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  after { Warden.test_reset! }

  it 'opens the discussion over the feed' do
    visit '/en/pins'

    find(".feed-discussion[data-feed-key='discussion-#{discussion.id}'] .feed-discussion-link").click

    expect(page).to have_css('.pin-viewer .pin-viewer-title', text: 'Recovery questions')
    expect(page).to have_css('.pin-viewer', text: 'What helped you most?')
    expect(page).to have_current_path("/en/discussions/#{discussion.id}")
  end

  it 'opens Reply with the cursor in the reply box' do
    visit '/en/pins'

    find(".feed-discussion[data-feed-key='discussion-#{discussion.id}'] .feed-discussion-reply").click

    expect(page).to have_css('.pin-viewer #commentable textarea')
    expect(page.evaluate_script("document.activeElement === document.querySelector('.pin-viewer #commentable textarea')")).to eq(true)
  end
end

RSpec.describe 'your own standalone discussion card', js: true do
  let!(:user) { create(:user, :with_confirmation) }
  let!(:discussion) { create(:discussion, user: user, title: 'Mine to delete') }

  before { login_as(user, scope: :user) }
  after { Warden.test_reset! }

  it 'can be deleted from the feed' do
    page.current_window.resize_to(390, 800)
    visit '/en/pins'

    card = ".feed-discussion[data-feed-key='discussion-#{discussion.id}']"
    accept_confirm { find("#{card} .feed-discussion-delete").click }

    expect(page).to have_no_css(card, visible: true)
    expect(Discussion.exists?(discussion.id)).to eq(false)
  end
end

RSpec.describe 'starting a discussion from the feed on a desktop', js: true do
  let!(:user) { create(:user, :with_confirmation) }

  before do
    create_list(:discussion, 3)
    login_as(user, scope: :user)
  end

  after { Warden.test_reset! }

  it 'puts the new card first in the grid' do
    visit '/en/pins'

    find('.feed-toolbar .feed-compose-toggle').click
    within('#feed-compose-panel') do
      fill_in 'discussion[title]', with: 'Desktop discussion'
      fill_in 'discussion[body]', with: 'Posted from a big screen.'
      click_button 'Post discussion'
    end

    expect(page).to have_css('#pins > .feed-discussion:first-child', text: 'Desktop discussion')
    expect(page).to have_no_css('#feed-compose-panel.in')
    # The grid lays the new card out at the top and moves the others down (an
    # animation of 0.4s), so nothing ends up on top of another card.
    overlapping = lambda do
      first, second = page.evaluate_script(<<~JS)
        Array.prototype.slice.call(document.querySelectorAll("#pins > .item"), 0, 2).map(function(el) {
          var r = el.getBoundingClientRect(); return { top: Math.round(r.top), left: Math.round(r.left), bottom: Math.round(r.bottom), right: Math.round(r.right) };
        })
      JS
      first["left"] < second["right"] && second["left"] < first["right"] && first["top"] < second["bottom"] && second["top"] < first["bottom"]
    end
    settled = Time.now + 3
    sleep 0.1 while overlapping.call && Time.now < settled
    expect(overlapping.call).to eq(false)
  end
end
