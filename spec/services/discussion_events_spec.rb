require 'rails_helper'

# Events for what the discussions work added: discussion cards in the feed
# (impressions and opens, for both standalone discussions and procedure/surgeon
# threads), and posting a discussion.
describe ContentEventBatchRecorder do
  let(:request) { double(remote_ip: '203.0.113.8') }

  def record(events)
    described_class.record_impressions(request: request, current_user: nil, locale: :en, visitor_id: 'browser', client_context: {}, events: events)
  end

  it 'records impressions of discussion cards alongside submissions' do
    pin = create(:pin)
    discussion = create(:discussion)
    thread = CommentService.new(create(:procedure), create(:user), 'How was recovery?').tap(&:create).comment

    count = record([
      { content_type: 'Pin', content_id: pin.id, event_type: 'impression', event_context: { rank: '1' } },
      { content_type: 'Discussion', content_id: discussion.id, event_type: 'impression', event_context: { rank: '2' } },
      { content_type: 'Comment', content_id: thread.id, event_type: 'impression', event_context: { rank: '3' } }
    ])

    expect(count).to eq(3)
    expect(ContentEvent.where(event_type: 'impression').pluck(:content_type, :content_id)).to match_array(
      [['Pin', pin.id], ['Discussion', discussion.id], ['Comment', thread.id]]
    )
    expect(ContentEvent.find_by(content_type: 'Discussion').event_context).to include('rank' => '2')
  end

  it 'keeps a discussion and a submission with the same id apart' do
    pin = create(:pin)
    discussion = create(:discussion)
    discussion.update_columns(id: pin.id)

    count = record([
      { content_type: 'Pin', content_id: pin.id, event_type: 'impression', event_context: {} },
      { content_type: 'Discussion', content_id: pin.id, event_type: 'impression', event_context: {} }
    ])

    expect(count).to eq(2)
    expect(ContentEvent.where(content_id: pin.id).pluck(:content_type)).to match_array(%w[Pin Discussion])
  end

  it "skips discussions that don't exist" do
    expect(record([{ content_type: 'Discussion', content_id: 999_999, event_type: 'impression', event_context: {} }])).to eq(0)
  end
end

describe ContentEventRecorder do
  let(:request) { double(remote_ip: '203.0.113.8') }

  it 'records opening a discussion card' do
    discussion = create(:discussion)

    expect(described_class.record(
      request: request, current_user: nil, locale: :en,
      content_type: 'Discussion', content_id: discussion.id, event_type: 'open',
      visitor_id: 'browser', event_context: { surface: 'pins_index', rank: '4' }
    )).to be(true)
    expect(ContentEvent.last).to have_attributes(content_type: 'Discussion', content_id: discussion.id, event_type: 'open')
  end
end

describe SubmissionEventRecorder do
  it 'records posting a discussion, from the server' do
    user = create(:user)
    discussion = create(:discussion, user: user)

    expect(described_class.record(content: discussion, user: user, event_type: 'discussion_created', locale: :en)).to be(true)
    expect(ContentEvent.last).to have_attributes(content_type: 'Discussion', content_id: discussion.id, event_type: 'discussion_created', source: 'server', user_id: user.id)
  end

  it "won't record a discussion event against a submission" do
    expect(described_class.record(content: create(:pin), user: create(:user), event_type: 'discussion_created', locale: :en)).to be(false)
  end
end

describe DiscussionsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in(user) }

  it 'records discussion_created when a discussion is posted from the feed' do
    post :create, params: { locale: 'en', discussion: { title: 'Recovery questions', body: 'What helped?', category: 'recovery', visibility: 'everyone' } }, xhr: true

    expect(ContentEvent.where(content_type: 'Discussion', content_id: Discussion.last.id, event_type: 'discussion_created', user_id: user.id).count).to eq(1)
  end

  it 'records discussion_created when posted from its own page' do
    post :create, params: { locale: 'en', discussion: { title: 'Recovery questions', body: 'What helped?', category: 'recovery', visibility: 'everyone' } }

    expect(ContentEvent.where(content_type: 'Discussion', event_type: 'discussion_created').count).to eq(1)
  end

  it "records nothing when the post doesn't save" do
    post :create, params: { locale: 'en', discussion: { title: '', body: '', category: 'recovery', visibility: 'everyone' } }, xhr: true

    expect(ContentEvent.count).to eq(0)
  end
end

describe PinsController, type: :controller do
  render_views

  let(:user) { create(:user) }

  before { sign_in(user) }

  def doc
    Nokogiri::HTML(response.body)
  end

  def context_of(element)
    JSON.parse(element['data-event-context'])
  end

  it 'marks both kinds of discussion card for impressions and opens, with their place in the feed' do
    discussion = create(:discussion)
    thread = CommentService.new(create(:procedure), create(:user), 'How was recovery?').tap(&:create).comment

    get :index, params: { locale: 'en' }

    [['Discussion', discussion.id, "discussion-#{discussion.id}"], ['Comment', thread.id, "comment-#{thread.id}"]].each do |type, id, key|
      card = doc.at_css(".feed-discussion[data-feed-key='#{key}']")
      marker = card.at_css('[data-content-event][data-event-type=impression]')
      expect(marker['data-content-type']).to eq(type)
      expect(marker['data-content-id']).to eq(id.to_s)
      expect(context_of(marker)).to include('surface' => 'pins_index', 'list_mode' => 'mixed')
      expect(context_of(marker)['rank']).to be_present

      topic = card.at_css('a.feed-discussion-link')
      expect(topic['data-content-event-open']).to be_present
      expect([topic['data-content-type'], topic['data-content-id']]).to eq([type, id.to_s])
    end
  end

  it 'tracks the toolbar buttons, in the toolbar and in the bottom bar separately' do
    get :index, params: { locale: 'en' }

    { '.feed-toolbar' => %w[feed_filter feed_discussion feed_submission], '.feed-dock' => %w[dock_filter dock_discussion dock_submission] }.each do |bar, targets|
      ids = doc.css("#{bar} .feed-toolbar-action").map do |action|
        expect(action['data-content-event-open']).to be_present
        expect(action['data-content-type']).to eq('Page')
        expect(context_of(action)).to include('surface' => bar.delete('.').tr('-', '_'))
        action['data-content-id'].to_i
      end
      expect(ids).to eq(targets.map { |target| TrackedTarget.id_for(target) })
    end
  end

  it 'tracks the search icon in the header' do
    get :index, params: { locale: 'en' }

    icon = doc.at_css('.header-search-open')
    expect(icon['data-content-id'].to_i).to eq(TrackedTarget.id_for(:search))
    expect(context_of(icon)).to include('surface' => 'header', 'target' => 'search')
  end
end

describe PinPresenter do
  it 'tells For You with filters apart from plain filters' do
    user = create(:user, gender: create(:gender, name: 'MTF'))
    surgeon = create(:surgeon)

    for_you = PinPresenter.new(current_user: user, feed: 'for_you', surgeon: [surgeon.id.to_s])
    plain = PinPresenter.new(current_user: user, surgeon: [surgeon.id.to_s])

    expect(for_you.list_event_context).to include(list_mode: 'filtered_for_you', ranking_version: 'filtered_for_you_v1')
    expect(plain.list_event_context).to include(list_mode: 'filtered', ranking_version: 'filtered_recent_activity_v1')
  end
end

describe TrackedTarget do
  it 'adds the new targets at the end without renumbering the old ones' do
    expect(TrackedTarget::TARGETS.values_at('news', 'safe_mode')).to eq([1, 19])
    expect(TrackedTarget::TARGETS.values_at('search', 'feed_filter', 'feed_discussion', 'feed_submission', 'dock_filter', 'dock_discussion', 'dock_submission')).to eq((20..26).to_a)
  end
end
