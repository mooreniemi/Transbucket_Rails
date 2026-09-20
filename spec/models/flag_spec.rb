require 'rails_helper'

describe Flag do
  # Creating a Pin/Comment also enqueues its own async Elasticsearch
  # reindex job (see Searchable#index_document_async), so counting all of
  # Delayed::Job is fragile. Scope to the job this spec actually cares about.
  def admin_review_job_count
    Delayed::Job.all.count { |job| job.payload_object.method_name == :admin_review_async_without_delay }
  end

  it '3 flags should make a pin pending' do
    pin = create(:pin)

    user = build_stubbed(:user)
    user2 = build_stubbed(:user)
    user3 = build_stubbed(:user)

    Flag.new(user, pin).flag_on
    Flag.new(user2, pin).flag_on
    Flag.new(user3, pin).flag_on

    expect(pin.pending?).to eq(true)
    expect(ModerationEvent.where(action: 'flag', content_type: 'Pin', content_id: pin.id).count).to eq(3)
    # TODO
    # expect(Delayed::Job.all.count).to eq(1)
  end

  it '3 flags should make a comment pending' do
    comment = create(:comment)
    allow_any_instance_of(Pin).to receive(:user).and_return(create(:user))

    user = create(:user)
    user2 = create(:user)
    user3 = create(:user)

    Flag.new(user, comment).flag_on
    Flag.new(user2, comment).flag_on
    Flag.new(user3, comment).flag_on

    expect(comment.pending?).to eq(true)
    expect(admin_review_job_count).to eq(1)
  end

  it "comment's parent pin author can send directly to pending" do
    pin_author = create(:user)
    pin = create(:pin, user: pin_author)
    comment_author = create(:user)
    comment = create(:comment, commentable_id: pin.id, user: comment_author)

    Flag.new(pin_author, comment).flag_on
    expect(comment.pending?).to eq(true)
    expect(admin_review_job_count).to eq(1)
  end
end
