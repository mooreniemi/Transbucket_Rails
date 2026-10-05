require 'rails_helper'

# The signed-in top bar on a phone: home, search, safe mode and the menu, each
# a comfortable 44px target. Search is an icon until you tap it, then the field
# takes over the bar with the keyboard up; Cancel puts the bar back. The menu
# doesn't repeat what is already in the bar or on the page. On a desktop the
# search field stays open as before.
RSpec.describe 'signed-in header', js: true do
  let!(:user) { create(:user, :with_confirmation) }

  before { login_as(user, scope: :user) }
  after { Warden.test_reset! }

  def box(selector)
    page.evaluate_script(<<~JS)
      (function() { var el = document.querySelector(#{selector.to_json});
        if (!el) { return null; }
        var r = el.getBoundingClientRect(); return { w: Math.round(r.width), h: Math.round(r.height) }; })()
    JS
  end

  context 'on a phone' do
    before { page.current_window.resize_to(390, 800) }

    it 'keeps home, search, safe mode and the menu at least 44px each, with search closed' do
      visit '/en/pins'

      ['.navbar-brand', '.header-search-open', '.safe-mode-form-bar .safe-mode-toggle', '.navbar-toggle'].each do |selector|
        size = box(selector)
        expect(size).to be_present, "#{selector} missing"
        expect(size['w']).to be >= 44, "#{selector} is #{size['w']}px wide"
        expect(size['h']).to be >= 44, "#{selector} is #{size['h']}px tall"
      end
      expect(page).to have_no_field('query')
    end

    it 'opens search over the bar with the cursor in it, and Cancel closes it' do
      visit '/en/pins'

      find('.header-search-open').click

      expect(page).to have_field('query')
      expect(page.evaluate_script('document.activeElement.id')).to eq('query')
      expect(page).to have_no_css('.navbar-brand', visible: true)
      expect(box('#query')['w']).to be >= 250

      click_button 'Cancel'

      expect(page).to have_no_field('query')
      expect(page).to have_css('.navbar-brand', visible: true)
    end

    it 'searches from the opened field' do
      visit '/en/procedures'

      find('.header-search-open').click
      fill_in 'query', with: 'metoidioplasty'
      find('#query').send_keys(:enter)

      expect(page).to have_current_path(/\/pins\?.*query=metoidioplasty/)
    end

    it "doesn't repeat safe mode or Filter in the menu" do
      visit '/en/pins'

      find('.navbar-toggle').click

      within('.navbar-collapse') do
        expect(page).to have_link('Procedures')
        expect(page).to have_no_css('.safe-mode-toggle', visible: true)
        expect(page).to have_no_link('Filter')
      end
    end
  end

  context 'on a desktop' do
    it 'keeps the search field open, with no search icon' do
      visit '/en/pins'

      expect(page).to have_field('query')
      expect(page).to have_no_css('.header-search-open', visible: true)
    end
  end
end
