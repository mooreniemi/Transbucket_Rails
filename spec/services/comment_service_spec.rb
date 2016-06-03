require 'spec_helper'

describe CommentService do
  let(:pin) { create(:pin) }
  let(:user) { create(:user, :wants_notifications) }

  it 'can create a comment and notify appropriately' do
    expect_any_instance_of(CommentMailer).to receive(:new_comment_email).
      and_return(true)

    CommentService.new(pin, user, "new comment").create
    expect(Comment.count).to eq(1)
  end

  it 'logs notification errors on comments' do
    expect_any_instance_of(CommentService).to receive(:send_email_notification).
      and_raise(Net::SMTPAuthenticationError)

    comment = CommentService.new(pin, user, text = "comment text").
      send(:create_and_notify)

    expect(comment.body).to eq(text)
  end
end
