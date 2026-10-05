require 'rails_helper'

RSpec.describe HomeFeedQuery do
  let(:user) { create(:user) }
  let(:procedure) { create(:procedure) }
  let(:surgeon) { create(:surgeon) }

  it 'orders published submissions and contextual root comments by recency' do
    pin = create(:pin, procedure: procedure, surgeon: surgeon, created_at: 2.days.ago)
    pin.update_columns(updated_at: 2.days.ago)
    # Feed recency is the latest photo activity (Pin.recent), so age the photos too.
    PinImage.where(pin_id: pin.id).update_all(created_at: 2.days.ago, updated_at: 2.days.ago, photo_updated_at: 2.days.ago)
    procedure_comment = Comment.create!(commentable: procedure, user: user, body: 'procedure discussion', created_at: 1.day.ago)
    surgeon_comment = Comment.create!(commentable: surgeon, user: user, body: 'surgeon discussion', created_at: 3.hours.ago)

    items = described_class.new(content: 'all').call

    expect(items.map(&:record)).to eq([surgeon_comment, procedure_comment, pin])
  end

  it 'filters to submissions only' do
    pin = create(:pin, procedure: procedure, surgeon: surgeon)
    Comment.create!(commentable: procedure, user: user, body: 'procedure discussion')

    items = described_class.new(content: 'submissions').call

    expect(items.map(&:record)).to eq([pin])
  end

  it 'filters to contextual discussions only and excludes replies' do
    root = Comment.create!(commentable: procedure, user: user, body: 'procedure discussion')
    reply = Comment.create!(commentable: procedure, user: user, body: 'reply')
    reply.move_to_child_of(root)

    items = described_class.new(content: 'discussions').call

    expect(items.map(&:record)).to eq([root])
  end

  # Pin.recent orders by the latest photo activity, not updated_at. Bulk tasks
  # touch updated_at on old pins, which must not move them up the feed.
  def pins_with_an_edited_old_one(count)
    pins = Array.new(count) do |i|
      create(:pin, procedure: procedure, surgeon: surgeon).tap do |pin|
        pin.update_columns(created_at: (count - i + 5).days.ago, updated_at: (count - i + 5).days.ago)
      end
    end
    PinImage.where(pin_id: pins.map(&:id)).update_all(created_at: 60.days.ago, updated_at: 60.days.ago, photo_updated_at: 60.days.ago)
    pins.first.update_columns(updated_at: 1.minute.ago)
    pins
  end

  it 'keeps submissions in the same order as the existing feed (Pin.recent)' do
    pins_with_an_edited_old_one(5)

    items = described_class.new(content: 'submissions', per_page: 10).call

    expect(items.map(&:record)).to eq(Pin.recent.to_a)
  end

  it 'shows every item exactly once when paging through the mixed feed' do
    pins = pins_with_an_edited_old_one(5)
    comments = [2, 7, 9].map { |days| Comment.create!(commentable: procedure, user: user, body: "discussion #{days}", created_at: days.days.ago) }

    shown = (1..5).flat_map { |page| described_class.new(content: 'all', page: page, per_page: 2).call.map(&:record) }

    expect(shown).to match_array(pins + comments)
    expect(shown.uniq.size).to eq(shown.size)
  end

  it 'counts published replies, including replies to replies, for each discussion' do
    root = Comment.create!(commentable: procedure, user: user, body: 'root')
    reply = Comment.create!(commentable: procedure, user: user, body: 'reply')
    reply.move_to_child_of(root)
    nested = Comment.create!(commentable: procedure, user: user, body: 'nested reply')
    nested.move_to_child_of(reply)
    hidden = Comment.create!(commentable: procedure, user: user, body: 'pending reply', state: 'pending')
    hidden.move_to_child_of(root)
    quiet = Comment.create!(commentable: surgeon, user: user, body: 'no replies yet')

    items = described_class.new(content: 'discussions').call.index_by(&:record)

    expect(items[root.reload].reply_count).to eq(2)
    expect(items[quiet].reply_count).to eq(0)
  end

  it 'applies discussion visibility for the feed viewer' do
    viewer = create(:user)
    hidden = Comment.create!(commentable: procedure, user: user, body: 'contributors only', visibility: 'contributors')
    visible = Comment.create!(commentable: procedure, user: user, body: 'public')

    expect(described_class.new(content: 'discussions', viewer: viewer).call.map(&:record)).to eq([visible])
    viewer.grant_trust!('contributor')
    expect(described_class.new(content: 'discussions', viewer: viewer).call.map(&:record)).to include(hidden, visible)
  end

  it 'mixes standalone discussion posts into the discussions feed' do
    post = create(:discussion, title: 'General question', created_at: 1.hour.ago)

    items = described_class.new(content: 'discussions', viewer: user).call

    expect(items.map(&:record)).to include(post)
    expect(items.find { |item| item.record == post }.kind).to eq('discussion_post')
  end
end
