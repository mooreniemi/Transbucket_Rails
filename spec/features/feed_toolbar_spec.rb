require 'rails_helper'

# The feed toolbar on a phone: Filter, + Discussion and + Submission in one row
# of 44px buttons. + Discussion opens a form above the feed like Filter does
# (one at a time) and posts without leaving the feed. Once the toolbar scrolls
# away the same buttons float at the bottom.
RSpec.describe 'feed toolbar on a phone', js: true do
  let!(:user) { create(:user, :with_confirmation) }

  before do
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  after { Warden.test_reset! }

  def boxes(selector)
    page.evaluate_script(<<~JS)
      Array.prototype.map.call(document.querySelectorAll(#{selector.to_json}), function(el) {
        var r = el.getBoundingClientRect(); return { top: Math.round(r.top), h: Math.round(r.height) };
      })
    JS
  end

  it 'shows the three in one row, each at least 44px tall' do
    visit '/en/pins'

    buttons = boxes('.feed-toolbar .feed-toolbar-action')
    expect(buttons.size).to eq(3)
    expect(buttons.map { |b| b['top'] }.uniq.size).to eq(1)
    expect(buttons.map { |b| b['h'] }).to all(be >= 44)
    expect(page.evaluate_script('document.documentElement.scrollWidth')).to be <= page.evaluate_script('window.innerWidth')
  end

  it 'opens the discussion form in place, with the cursor in the title, one panel at a time' do
    visit '/en/pins'

    find('.feed-toolbar .feed-compose-toggle').click
    expect(page).to have_css('#feed-compose-panel.in .discussion-form')
    expect(page.evaluate_script('document.activeElement.name')).to eq('discussion[title]')

    find('.feed-toolbar .feed-filter-toggle').click
    expect(page).to have_css('#feed-filter-panel.in')
    expect(page).to have_no_css('#feed-compose-panel.in')
  end

  it 'posts a discussion without leaving the feed and puts it at the top' do
    visit '/en/pins'

    find('.feed-toolbar .feed-compose-toggle').click
    within('#feed-compose-panel') do
      fill_in 'discussion[title]', with: 'Who has done metoidioplasty recently?'
      find('label', text: 'Question').click
      fill_in 'discussion[body]', with: 'Looking for recent experiences with recovery time.'
      click_button 'Post discussion'
    end

    expect(page).to have_css('#pins > .feed-discussion:first-child', text: 'Who has done metoidioplasty recently?')
    expect(page).to have_no_css('#feed-compose-panel.in')
    expect(page).to have_current_path('/en/pins')
    expect(Discussion.last.category).to eq('question')
  end

  it 'shows what to fix in the form when something is wrong' do
    visit '/en/pins'

    find('.feed-toolbar .feed-compose-toggle').click
    within('#feed-compose-panel') do
      fill_in 'discussion[title]', with: 'Hi'
      fill_in 'discussion[body]', with: 'Too short a title'
      click_button 'Post discussion'
    end

    expect(page).to have_css('#feed-compose-panel .control-group.error', text: 'too short')
    expect(page).to have_current_path('/en/pins')
    expect(Discussion.count).to eq(0)
  end

  it 'floats the buttons at the bottom once the toolbar scrolls away, and they open the form back up top' do
    create_list(:discussion, 8)
    visit '/en/pins'
    expect(page).to have_no_css('.feed-dock', visible: true)

    page.execute_script('window.scrollTo(0, 1200)')
    expect(page).to have_css('.feed-dock', visible: true)
    dock = boxes('.feed-dock .feed-toolbar-action')
    expect(dock.size).to eq(3)
    expect(dock.map { |b| b['h'] }).to all(be >= 44)

    find('.feed-dock .feed-compose-toggle').click

    expect(page).to have_css('#feed-compose-panel.in .discussion-form')
    expect(page).to have_no_css('.feed-dock', visible: true)
  end
end
