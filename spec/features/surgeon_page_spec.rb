require 'rails_helper'

# The surgeon page on a phone must not leave dead space: Bootstrap's media
# object kept a column for the big doctor icon down the whole page, and the
# recent-submission photos left an empty strip beside them.
RSpec.describe 'the surgeon page', js: true, fake_images: true do
  let!(:user) { create(:user, :with_confirmation) }
  let!(:surgeon) { create(:surgeon) }
  let!(:pins) { create_list(:pin, 2, user: user, surgeon: surgeon) }

  before do
    Rails.cache.clear
    login_as(user, scope: :user)
  end

  after { Warden.test_reset! }

  def left_of(selector)
    page.evaluate_script("Math.round(document.querySelector(#{selector.to_json}).getBoundingClientRect().left)")
  end

  def page_content_left
    page.evaluate_script(<<-JAVASCRIPT)
      (function() {
        var container = document.querySelector('body > .container');
        return Math.round(container.getBoundingClientRect().left + parseFloat(getComputedStyle(container).paddingLeft));
      }())
    JAVASCRIPT
  end

  it 'uses the full width on a phone, with a small icon before the name' do
    page.current_window.resize_to(390, 800)
    visit "/en/surgeons/#{surgeon.id}"

    expect(page).to have_css('.surgeon-profile h1', text: surgeon.to_s)
    expect(page).to have_css('.surgeon-profile h1 .surgeon-heading-icon', visible: true)
    expect(page).not_to have_css('.surgeon-profile-icon', visible: true)

    # Name, address and the submissions all start at the page's own margin.
    %w(.surgeon-profile\ h1 .surgeon-profile\ address .procedure-recent-submissions).each do |selector|
      expect(left_of(selector)).to eq(page_content_left), "#{selector} is indented"
    end

    # Each submission's photo box spans its card's content width.
    gaps = page.evaluate_script(<<-JAVASCRIPT)
      Array.prototype.map.call(document.querySelectorAll('.procedure-recent-pin'), function(card) {
        var box = card.querySelector('.pin-card-image').getBoundingClientRect();
        var details = card.querySelector('.procedure-recent-pin-details').getBoundingClientRect();
        return Math.round(Math.abs(box.width - details.width));
      })
    JAVASCRIPT
    expect(gaps).not_to be_empty
    expect(gaps).to all(be <= 1)
  end

  it 'keeps the big icon column on a wide screen' do
    visit "/en/surgeons/#{surgeon.id}"

    expect(page).to have_css('.surgeon-profile-icon', visible: true)
    expect(page).not_to have_css('.surgeon-heading-icon', visible: true)
  end
end
