class CommentMailer < ActionMailer::Base
  default from: "admin@transbucket.com"

  def new_comment_email(receiver_id, about_id)
    @user = User.find(receiver_id)
    @url  = 'http://www.transbucket.com/pins/' + about_id
    mail(to: @user.email, subject: 'New Comments on Your Submission')
  end
end
