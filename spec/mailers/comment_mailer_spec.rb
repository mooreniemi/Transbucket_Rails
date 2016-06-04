require "spec_helper"

describe CommentMailer do
	let(:user) { create(:user) }
	let(:commentable) { build(:pin, user: user) }
	let(:body) {"all right"}
	let(:mail) do
		CommentMailer.new_comment_email(user.id, commentable.id)
	end
	it "should have the right subject line" do
		expect(mail.subject).to eq("Transbucket.com: New Comments on #{commentable.id}")
	end
	it "should have the right url" do
		comment_url = "http://www.transbucket.com/pins/#{commentable.id}" +
			"?utm_source=comment_reminder&amp;utm_medium=email&amp;utm_campaign=comment_reminder"
		expect(mail.body.raw_source).to include(comment_url)
	end
end
