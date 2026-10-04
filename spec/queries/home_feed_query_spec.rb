require 'rails_helper'

RSpec.describe HomeFeedQuery do
  let(:user) { create(:user) }
  let(:procedure) { create(:procedure) }
  let(:surgeon) { create(:surgeon) }

  it 'orders published submissions and contextual root comments by recency' do
    pin = create(:pin, procedure: procedure, surgeon: surgeon, created_at: 2.days.ago)
    pin.update_columns(updated_at: 2.days.ago)
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
end
