require 'rails_helper'

describe CommentService do
	let(:user) { create(:user, :wants_notifications) }
	let(:commenter) { create(:user) }
	let(:pin) { create(:pin, user: user) }

	it 'can create a comment and notify appropriately' do
		expect_any_instance_of(CommentMailer).to receive(:new_comment_email).with(
			user.id, pin.id, false).and_return(true)

		CommentService.new(pin, commenter, "new comment").create
		expect(Comment.count).to eq(1)
	end

  it 'doesnt notify a user they commented on their own submission' do
    expect_any_instance_of(CommentMailer).to_not receive(:new_comment_email)

    CommentService.new(pin, user, "my own comment").create
    expect(Comment.count).to eq(1)
  end

  context "with a pin with no user" do
    let(:pin) { create(:pin) }

    it 'creates a comment with no notification' do
      expect_any_instance_of(CommentMailer).not_to receive(:new_comment_email)

      CommentService.new(pin, commenter, "new comment").create
      expect(Comment.count).to eq(1)
    end
  end

	it 'logs notification errors on comments' do
		expect_any_instance_of(CommentService).to receive(:send_email_notification).
			and_raise(Net::SMTPAuthenticationError)

    text = "comment text"

    expected_error = "Net::SMTPAuthenticationError was raised while " +
                     "attempting to send notification on Pin #{pin.id} " +
                     "to User #{user.id}\n"

    expect {
		  CommentService.new(pin, user, text).send(:notify_author)
    }.to output(expected_error).to_stdout
	end

  it "respects notification settings" do
    preferences = user.preference
    preferences.notification = false
    preferences.save!

    expect_any_instance_of(CommentMailer).not_to receive(:new_comment_email)
    CommentService.new(pin, commenter, "example not notified").create
  end
end
