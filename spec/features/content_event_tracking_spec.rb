require 'rails_helper'

RSpec.describe 'Pin-list activity tracking', js: true, fake_images: true do
  let!(:user) { create(:user, :with_confirmation) }
  let!(:pin) { create(:pin, user: user) }

  after { Warden.test_reset! }

  def wait_for_event(attributes)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        return if ContentEvent.where(attributes).exists?

        sleep 0.05
      end
    end
  end

  it 'records a real Pin card impression, open, and detail view' do
    login_as(user, scope: :user)

    visit '/en/pins'

    impression_attributes = { user: user, content_type: 'Pin', content_id: pin.id, event_type: 'impression' }
    wait_for_event(impression_attributes)
    expect(ContentEvent.find_by(impression_attributes).event_context).to include(
      'surface' => 'pins_index', 'list_mode' => 'recent', 'rank' => '1', 'ranking_version' => 'recent_submission_activity_v1'
    )

    find(".item[data-pin-id='#{pin.id}'] .pin-card-image a").click

    expect(page).to have_current_path("/en/pins/#{pin.id}")
    expect(page).to have_css('.pin-page-title')
    open_attributes = { user: user, content_type: 'Pin', content_id: pin.id, event_type: 'open' }
    wait_for_event(open_attributes)
    expect(ContentEvent.find_by(open_attributes).event_context).to include(
      'surface' => 'pins_index', 'list_mode' => 'recent', 'rank' => '1', 'ranking_version' => 'recent_submission_activity_v1'
    )
    wait_for_event(user: user, content_type: 'Pin', content_id: pin.id, event_type: 'view')
  end
end
