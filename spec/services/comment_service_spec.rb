require 'rails_helper'

describe CommentService do
	let(:user) { create(:user, :wants_notifications) }
	let(:commenter) { create(:user) }
	let(:pin) { create(:pin, user: user) }

	it 'can create a comment and notify appropriately' do
		expect_any_instance_of(CommentMailer).to receive(:new_comment_email).with(
			user.id, pin.id).and_return(true)

		CommentService.new(pin, commenter, "new comment").create
		expect(Comment.count).to eq(1)
	end

	it 'logs notification errors on comments' do
		expect_any_instance_of(CommentService).to receive(:send_email_notification).
			and_raise(Net::SMTPAuthenticationError)

    comment = nil
    text = "comment text"

    expected_error = "Net::SMTPAuthenticationError was raised while " +
                     "attempting to send notification on Pin #{pin.id} " +
                     "to User #{user.id}\n"

    expect {
		  comment = CommentService.new(pin, user, text).send(:create_and_notify)
    }.to output(expected_error).to_stdout

		expect(comment.body).to eq(text)
	end
end
