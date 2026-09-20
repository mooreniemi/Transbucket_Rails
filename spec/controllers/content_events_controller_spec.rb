require 'rails_helper'

describe ContentEventsController, type: :controller do
  describe '#create' do
    it 'records an anonymous public procedure view and always returns no content' do
      procedure = create(:procedure)

      post :create, locale: :en, content_type: 'Procedure', content_id: procedure.id, event_type: 'view',
        client_context: { device_class: 'mobile', browser_family: 'Firefox', browser_major: '130', os_family: 'Android', viewport_bucket: 'small', beacon: 'yes', fetch: 'yes', save_data: 'no', connection_type: '4g' },
        event_context: { surface: 'pins_index', list_mode: 'recent', filter_signature: '', rank: '1', ranking_version: 'recent_submission_activity_v1', ignored: 'nope' }

      expect(response).to have_http_status(:no_content)
      event = ContentEvent.last
      expect(event).to have_attributes(content_type: 'Procedure', content_id: procedure.id, event_type: 'view')
      expect(event.client_context).to include('device_class' => 'mobile', 'browser_family' => 'Firefox', 'os_family' => 'Android')
      expect(event.event_context).to eq('surface' => 'pins_index', 'list_mode' => 'recent', 'filter_signature' => '', 'rank' => '1', 'ranking_version' => 'recent_submission_activity_v1')
      expect(event.user).to be_nil
      expect(cookies.signed[:content_event_visitor_id]).to be_present
    end

    it 'associates a signed-in visitor without setting anonymous identifiers' do
      procedure = create(:procedure)
      user = create(:user)
      sign_in user

      post :create, locale: :en, content_type: 'Procedure', content_id: procedure.id, event_type: 'view'

      expect(response).to have_http_status(:no_content)
      expect(ContentEvent.last).to have_attributes(user: user, visitor_hash: nil, network_hash: nil)
      expect(cookies.signed[:content_event_visitor_id]).to be_nil
    end

    it 'silently ignores an invalid or nonexistent target' do
      expect {
        post :create, locale: :en, content_type: 'Pin', content_id: 999_999, event_type: 'gallery_open'
      }.not_to change(ContentEvent, :count)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns no content even if the recorder itself raises unexpectedly' do
      allow(ContentEventRecorder).to receive(:record).and_raise(StandardError, 'unexpected telemetry failure')

      post :create, locale: :en, content_type: 'Procedure', content_id: 123, event_type: 'view'

      expect(response).to have_http_status(:no_content)
    end
  end

  describe '#batch' do
    it 'records valid Pin impressions and ignores non-Pin batch entries' do
      first_pin, second_pin = create_list(:pin, 2)

      post :batch, locale: :en, events: {
        '0' => { content_type: 'Pin', content_id: first_pin.id, event_type: 'impression', event_context: { surface: 'pins_index', rank: '1' } },
        '1' => { content_type: 'Pin', content_id: second_pin.id, event_type: 'impression', event_context: { surface: 'pins_index', rank: '2' } },
        '2' => { content_type: 'Surgeon', content_id: 123, event_type: 'impression' }
      }

      expect(response).to have_http_status(:no_content)
      expect(ContentEvent.where(event_type: 'impression').pluck(:content_id)).to match_array([first_pin.id, second_pin.id])
    end
  end
end
