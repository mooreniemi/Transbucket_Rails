require 'rails_helper'

# The submissions feed on a phone: infinite scroll (feed_scroll.js), pins
# opened over the feed and closed without losing your place (pin_viewer.js),
# and photos fitted to the card's box (card_photo_fit.js).
RSpec.describe 'the submissions feed on a phone', js: true, fake_images: true do
  let!(:user) { create(:user, :with_confirmation) }

  before do
    Rails.cache.clear
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  after do
    begin
      # The viewer loads full-size photos. Let any still downloading finish, or
      # they reach the server after the fake_images route is removed and fail
      # the example with a routing error. Lazy photos far off screen are never
      # requested, so they are not waited for.
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop do
          settled = page.evaluate_script(<<-JAVASCRIPT)
            Array.prototype.every.call(document.images, function(img) {
              if (img.complete) { return true; }
              var rect = img.getBoundingClientRect();
              return img.loading === 'lazy' && (rect.top > window.innerHeight + 3000 || rect.bottom < -3000);
            })
          JAVASCRIPT
          break if settled
          sleep 0.05
        end
      end
    rescue Timeout::Error
      # Best effort: a slow photo should not fail the example.
    ensure
      # Always back to the desktop size the other specs expect: below 768px
      # the pin form swaps its dropdowns for touch pickers.
      page.current_window.resize_to(1400, 1000)
      Warden.test_reset!
    end
  end

  def wait_for_event(attributes)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        return if ContentEvent.where(attributes).exists?

        sleep 0.05
      end
    end
  end

  def scroll_y
    page.evaluate_script('window.scrollY')
  end

  def card_link(pin)
    find(".item[data-pin-id='#{pin.id}'] .pin-card-image a")
  end

  describe 'infinite scroll' do
    before do
      allow(Pin).to receive(:per_page).and_return(2)
      @pins = create_list(:pin, 5, user: user)
    end

    it 'loads every page into the feed as you scroll, without repeats, then says you are caught up' do
      visit '/en/pins'

      # Page 1 is two cards; with cards this short the next page may already be
      # on its way, since loading starts well before the bottom is reached.
      expect(page).to have_css('#pins .item', minimum: 2)
      expect(page).not_to have_css('#paginator', visible: true)

      5.times do
        break if page.has_css?('#pins .item', count: 5, wait: 1)
        page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
      end

      expect(page).to have_css('#pins .item', count: 5)
      ids = all('#pins .item').map { |item| item['data-pin-id'].to_i }
      expect(ids).to match_array(@pins.map(&:id))
      expect(page).to have_css('.feed-scroll-status', text: I18n.t('directory.end_of_feed'))
    end

    it 'records impressions for the cards it adds' do
      visit '/en/pins'
      5.times do
        break if page.has_css?('#pins .item', count: 5, wait: 1)
        page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
      end

      last = Pin.order(:created_at).first
      wait_for_event(user: user, content_type: 'Pin', content_id: last.id, event_type: 'impression')
    end
  end

  describe 'the pin viewer' do
    let!(:pins) { create_list(:pin, 3, :with_surgeon_and_procedure, user: user) }
    let(:pin) { pins.first }

    it 'opens a pin over the feed and the close button puts you back where you were' do
      visit '/en/pins'
      page.execute_script("document.querySelector(\".item[data-pin-id='#{pin.id}']\").scrollIntoView()")
      before = scroll_y

      card_link(pin).click

      expect(page).to have_css('.pin-viewer', visible: true)
      expect(page).to have_css('.pin-viewer .pin-meta')
      expect(page).to have_current_path("/en/pins/#{pin.id}")
      expect(find('.pin-viewer-title').text).to include(pin.procedure.localized_name)
      wait_for_event(user: user, content_type: 'Pin', content_id: pin.id, event_type: 'view')

      find('.pin-viewer-close').click

      expect(page).not_to have_css('.pin-viewer', visible: true)
      expect(page).to have_current_path('/en/pins')
      expect(scroll_y).to eq(before)
      expect(page).to have_css('#pins .item', count: 3)
    end

    it 'closes with the browser back button and reopens with forward' do
      visit '/en/pins'
      card_link(pin).click
      expect(page).to have_css('.pin-viewer .pin-meta')

      page.go_back
      expect(page).not_to have_css('.pin-viewer', visible: true)
      expect(page).to have_current_path('/en/pins')

      page.go_forward
      expect(page).to have_css('.pin-viewer .pin-meta')
      expect(page).to have_current_path("/en/pins/#{pin.id}")
    end

    it 'closes with Escape' do
      visit '/en/pins'
      card_link(pin).click
      expect(page).to have_css('.pin-viewer .pin-meta')

      find('.pin-viewer-close').send_keys(:escape)

      expect(page).not_to have_css('.pin-viewer', visible: true)
      expect(page).to have_current_path('/en/pins')
    end

    it 'shows the real pin page when the pinned URL is loaded directly' do
      visit '/en/pins'
      card_link(pin).click
      expect(page).to have_css('.pin-viewer .pin-meta')

      visit current_path

      expect(page).to have_css('.navbar-fixed-top')
      expect(page).to have_css('.pin-page-title')
      expect(page).not_to have_css('.pin-viewer')
    end

    it 'lets you comment, and report a comment, without leaving the feed' do
      commenter = create(:user, :with_confirmation)
      create(:comment, commentable: pin, user: commenter, body: 'Someone else said this')

      visit '/en/pins'
      card_link(pin).click
      expect(page).to have_css('.pin-viewer .comments-heading', text: '1')

      within('.pin-viewer #commentable') do
        fill_in 'comment[body]', with: 'Thanks for sharing'
        click_button 'Post'
      end
      expect(page).to have_css('.pin-viewer .comment-list .comment-body', text: 'Thanks for sharing')

      # A report from the pin's own author sends the comment straight to review.
      within('.pin-viewer .comment', text: 'Someone else said this') do
        accept_confirm { click_link I18n.t('public.pin.report') }
      end
      expect(page).not_to have_css('.pin-viewer .comment', text: 'Someone else said this')
      expect(page).to have_current_path("/en/pins/#{pin.id}")
    end

    it 'shows that a comment was reported when someone else reports it in the viewer' do
      author = create(:user, :with_confirmation)
      other_pin = create(:pin, :with_surgeon_and_procedure, user: author)
      create(:comment, commentable: other_pin, user: author, body: 'A comment to report')

      visit '/en/pins'
      card_link(other_pin).click

      within('.pin-viewer .comment', text: 'A comment to report') do
        accept_confirm { click_link I18n.t('public.pin.report') }
        expect(page).to have_css('.flag-reported', text: I18n.t('public.pin.reported'))
      end
    end

    it 'opens a card comment link at the discussion' do
      create(:comment, commentable: pin, user: user)
      visit '/en/pins'

      find(".item[data-pin-id='#{pin.id}'] .pin-comment-count").click

      expect(page).to have_css('.pin-viewer #comments-container')
      expect(page.current_url).to end_with("/en/pins/#{pin.id}#comments-container")
      top = page.evaluate_script("document.getElementById('comments-container').getBoundingClientRect().top")
      bar = page.evaluate_script("document.querySelector('.pin-viewer-bar').getBoundingClientRect().bottom")
      max_scroll = page.evaluate_script("(function(b){ return b.scrollHeight - b.clientHeight - b.scrollTop; })(document.querySelector('.pin-viewer-body'))")
      # At the top of the viewer, unless the page is too short to scroll that far.
      expect((top - bar).abs < 2 || max_scroll < 2).to be(true)
    end

    it 'leaves ordinary links alone on wider screens' do
      page.current_window.resize_to(1400, 1000)
      visit '/en/pins'

      card_link(pin).click

      expect(page).to have_current_path("/en/pins/#{pin.id}")
      expect(page).to have_css('.navbar-fixed-top')
      expect(page).not_to have_css('.pin-viewer', visible: true)
    end
  end

  describe 'safe mode' do
    let!(:pin) { create(:pin, :with_surgeon_and_procedure, user: create(:user)) }

    before { user.preference.update!(safe_mode: true) }

    it 'keeps photos blurred in the viewer until tapped, and the reveal does not close it' do
      visit '/en/pins'
      # The card's reveal button must be tapped first; the blurred photo itself
      # does not open the pin.
      find(".item[data-pin-id='#{pin.id}'] [data-safe-reveal]").click
      card_link(pin).click
      expect(page).to have_css('.pin-viewer .pin-meta')

      expect(page).to have_css('.pin-viewer .pin-gallery-photo.safe-blur:not(.is-revealed)', minimum: 1)
      first('.pin-viewer [data-safe-reveal]').click

      expect(page).to have_css('.pin-viewer .pin-gallery-photo.safe-blur.is-revealed', minimum: 1)
      expect(page).to have_css('.pin-viewer', visible: true)
      expect(page).to have_current_path("/en/pins/#{pin.id}")
    end
  end

  describe 'the new-comment preview on a card' do
    let!(:pin) { create(:pin, :with_surgeon_and_procedure, user: create(:user)) }
    let!(:commenter) { create(:user, :with_confirmation, username: 'kindperson') }
    let!(:comment) { create(:comment, commentable: pin, user: commenter, body: 'fresh words on this pin') }

    before do
      # Signing in makes the previous sign-in the "last visit", so put both
      # before the comment.
      user.update_columns(last_sign_in_at: 2.days.ago, current_sign_in_at: 2.days.ago)
      comment.update_column(:created_at, 1.day.ago)
    end

    def preview_below_photo?
      page.evaluate_script(<<-JAVASCRIPT)
        (function() {
          var preview = document.querySelector('.pin-card-latest-comment');
          var photo = preview.closest('.item').querySelector('.pin-card-image');
          return preview.getBoundingClientRect().top >= photo.getBoundingClientRect().bottom;
        }())
      JAVASCRIPT
    end

    it 'shows who said what under the caption, clear of the photo' do
      visit '/en/pins'

      preview = find('.pin-card-latest-comment')
      expect(preview).to have_css('strong', text: 'kindperson')
      expect(preview).to have_text('fresh words on this pin')
      expect(preview_below_photo?).to be(true)
    end

    it 'opens the pin in the viewer at that comment' do
      visit '/en/pins'

      find('.pin-card-latest-comment').click

      expect(page).to have_css(".pin-viewer #comment-#{comment.id}")
      expect(page.current_url).to end_with("/en/pins/#{pin.id}#comment-#{comment.id}")
    end

    it 'is clear of the photo on a wide screen too' do
      page.current_window.resize_to(1400, 1000)
      visit '/en/pins'

      expect(page).to have_css('.pin-card-latest-comment', text: 'fresh words on this pin')
      expect(preview_below_photo?).to be(true)
    end
  end

  describe 'fitting photos to the card' do
    let!(:pin) { create(:pin, user: user) }

    def fit_class_for(width, height)
      page.evaluate_async_script(<<-JAVASCRIPT, width, height)
        var width = arguments[0], height = arguments[1], done = arguments[2];
        var canvas = document.createElement('canvas');
        canvas.width = width; canvas.height = height;
        canvas.getContext('2d').fillRect(0, 0, width, height);
        var box = document.createElement('div'), link = document.createElement('a'), img = document.createElement('img');
        box.className = 'image pin-card-image';
        link.appendChild(img); box.appendChild(link); document.body.appendChild(box);
        img.onload = function() { setTimeout(function() { done(box.className); }, 0); };
        img.src = canvas.toDataURL();
      JAVASCRIPT
    end

    it 'fills the box with a photo close to its shape and shows a far-off one whole over a blurred copy' do
      visit '/en/pins'

      expect(fit_class_for(360, 240)).to include('is-filled')   # 3:2
      expect(fit_class_for(320, 240)).to include('is-filled')   # 4:3
      expect(fit_class_for(240, 320)).to include('has-backdrop') # 3:4 portrait
      expect(fit_class_for(320, 180)).to include('has-backdrop') # 16:9
    end
  end
end
