require 'rails_helper'

# Procedure and surgeon pages on a phone: the title and actions are on the
# first screen, everything tappable is at least 44px, recent submissions swipe
# sideways instead of stretching the page, and nothing scrolls the page
# sideways. On a desktop the reference guide starts open.
RSpec.describe 'procedure and surgeon pages on a phone', js: true, fake_images: true do
  let!(:user) { create(:user, :with_confirmation) }
  let!(:procedure) { create(:procedure, name: 'double incision') }
  let!(:surgeon) { create(:surgeon) }

  before do
    create_list(:pin, 3, user: user, procedure: procedure, surgeon: surgeon, sensation: 4, satisfaction: 3)
    login_as(user, scope: :user)
    page.current_window.resize_to(390, 800)
  end

  after do
    page.current_window.resize_to(1400, 1000)
    Warden.test_reset!
  end

  def measure(selector)
    page.evaluate_script(<<~JS)
      Array.prototype.map.call(document.querySelectorAll(#{selector.to_json}), function(el) {
        var r = el.getBoundingClientRect(); return { h: Math.round(r.height), bottom: Math.round(r.bottom) };
      })
    JS
  end

  ['/en/procedures/%s', '/en/surgeons/%s'].each do |pattern|
    describe pattern.split('/')[2] do
      let(:path) { format(pattern, pattern.include?('procedures') ? procedure.to_param : surgeon.to_param) }

      it 'shows the title and the actions on the first screen' do
        visit path

        actions = measure('.subject-actions a')
        expect(actions.size).to eq(3)
        expect(actions.map { |a| a['bottom'] }.max).to be <= page.evaluate_script('window.innerHeight')
      end

      it 'keeps everything tappable at least 44px tall' do
        visit path

        heights = measure('.subject-actions a, a.rating-distribution-count-link, a.subject-count-badge, a.start-discussion').map { |m| m['h'] }
        expect(heights).not_to be_empty
        expect(heights).to all(be >= 44)
      end

      it 'swipes through recent submissions in a row without widening the page' do
        visit path

        row = page.evaluate_script(<<~JS)
          (function() { var el = document.querySelector('.procedure-recent-pin-list');
            return { scrolls: el.scrollWidth > el.clientWidth, overflow: getComputedStyle(el).overflowX }; })()
        JS
        expect(row).to eq('scrolls' => true, 'overflow' => 'auto')
        expect(page.evaluate_script('document.documentElement.scrollWidth')).to be <= page.evaluate_script('window.innerWidth')
      end
    end
  end

  it 'starts the procedure guide closed on a phone and open on a desktop' do
    allow_any_instance_of(Procedure).to receive(:editorial_guide).and_return(
      'summary' => 'A summary.', 'sources' => [{ 'name' => 'Source', 'url' => 'https://example.org' }]
    )

    visit "/en/procedures/#{procedure.to_param}"
    expect(page.evaluate_script("document.querySelector('details.subject-reference').open")).to eq(false)

    page.current_window.resize_to(1400, 1000)
    visit "/en/procedures/#{procedure.to_param}"
    expect(page.evaluate_script("document.querySelector('details.subject-reference').open")).to eq(true)
  end
end
