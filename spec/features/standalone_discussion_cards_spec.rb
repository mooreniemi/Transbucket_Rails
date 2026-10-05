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
