require 'rails_helper'

# Start a discussion in the phone menu: from any page it lands on the feed
# with the discussion form open and the cursor in the title; on the feed it
# just opens the form, without reloading.
RSpec.describe 'Start a discussion from the menu, on a phone', js: true do
  let!(:user) { create(:user, :with_confirmation) }

  before do
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  after { Warden.test_reset! }

  def title_focused?
    page.evaluate_script('document.activeElement && document.activeElement.name') == 'discussion[title]'
  end

  it 'goes from another page to the feed with the form open, ready to type' do
    visit '/en/procedures'

    find('.navbar-toggle').click
    click_link 'Start a discussion'

    expect(page).to have_current_path('/en/pins?compose=1')
    expect(page).to have_css('#feed-compose-panel.in .discussion-form')
    expect(title_focused?).to eq(true)
  end

  it 'opens the form in place when already on the feed' do
    visit '/en/pins'
    page.execute_script('window.notReloaded = true')

    find('.navbar-toggle').click
    click_link 'Start a discussion'

    expect(page).to have_css('#feed-compose-panel.in .discussion-form')
    expect(page).to have_no_css('.navbar-collapse.in')
    expect(page.evaluate_script('window.notReloaded')).to eq(true)
    expect(page).to have_current_path('/en/pins')
  end
end
