require "spec_helper"

describe CommentMailer do
  let(:user) { build(:user) }
  let(:commentable) { build(:pin, user: user) }
  let(:body) {"all right"}
  let(:comments_service) {CommentService.new(commentable, user, body)}
  let(:mail) {CommentMailer.new_comment_email(comments_service)}
  it "should have the right subject line" do
    expect(mail.subject).to eq("New Comments on Your Submission")
  end
  it "should have the right url" do
    expect(mail.body.raw_source).to include("http://www.transbucket.com/pins/#{commentable.id}?utm_source=comment_reminder&amp;utm_medium=email&amp;utm_campaign=comment_reminder")
  end
end
