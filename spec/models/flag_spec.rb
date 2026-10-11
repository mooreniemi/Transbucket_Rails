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
    comment = create(:comment, commentable: pin, user: comment_author)

    Flag.new(pin_author, comment).flag_on
    expect(comment.pending?).to eq(true)
    expect(admin_review_job_count).to eq(1)
  end

  # Comments now live on procedures and surgeons too, not only on pins.
  describe 'reporting a comment on a procedure or surgeon thread' do
    let(:reporter) { create(:user) }

    [:procedure, :surgeon].each do |kind|
      it "records a down-vote on a #{kind} comment without looking for a pin" do
        commentable = create(kind)
        comment = Comment.create!(commentable: commentable, user: create(:user), body: "On a #{kind}")

        expect(Flag.new(reporter, comment).flag_on).to eq(status: :voted_down)
        expect(comment.reload).to be_published
      end
    end

    it 'does not treat the reporter as the author of an unrelated pin that shares the id' do
      procedure = create(:procedure)
      comment = Comment.create!(commentable: procedure, user: create(:user), body: 'Procedure thread')
      unrelated_pin = create(:pin, user: reporter)
      unrelated_pin.update_columns(id: procedure.id) unless Pin.exists?(procedure.id)

      expect(Flag.new(reporter, comment).flag_on).to eq(status: :voted_down)
      expect(comment.reload).to be_published
    end
  end
end
