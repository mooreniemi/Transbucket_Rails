require 'rails_helper'

describe CommentMailer do
  let(:user) { create(:user) }
  let(:commentable) { create(:pin, user: user) }
  describe "comment doesn't contain question" do
    let(:comment_mail) do
      CommentMailer.new_comment_email(user.id, commentable.id)
    end
    it "should have the right subject line" do
      expect(comment_mail.subject).to eq("Transbucket.com: New Comment on #{commentable.id}")
    end
    it "should have the right url" do
      comment_url = "https://www.transbucket.com/pins/#{commentable.id}" +
        "?utm_source=comment_reminder&amp;utm_medium=email&amp;utm_campaign=comment_reminder"
        expect(comment_mail.body.raw_source).to include(comment_url)
    end
    it "should have the unsub url" do
      comment_url = "https://www.transbucket.com/users/#{user.id}/edit" +
        "?utm_source=comment_reminder&amp;utm_medium=email&amp;utm_campaign=comment_reminder"
        expect(comment_mail.body.raw_source).to include(comment_url)
    end
  end
  describe "comment contains a question" do
    let(:question_mail) do
      CommentMailer.new_comment_email(user.id, commentable.id, true)
    end
    it "should have the right subject line" do
      expect(question_mail.subject).to eq("Transbucket.com: New Question on #{commentable.id}")
    end
    it "should have the right url" do
      comment_url = "https://www.transbucket.com/pins/#{commentable.id}" +
        "?utm_source=comment_reminder&amp;utm_medium=email&amp;utm_campaign=question_reminder"
        expect(question_mail.body.raw_source).to include(comment_url)
    end
    it "should have the unsub url" do
      comment_url = "https://www.transbucket.com/users/#{user.id}/edit" +
        "?utm_source=comment_reminder&amp;utm_medium=email&amp;utm_campaign=question_reminder"
        expect(question_mail.body.raw_source).to include(comment_url)
    end
  end
end
