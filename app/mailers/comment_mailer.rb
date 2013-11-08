class CommentMailer < ActionMailer::Base
  default from: "admin@transbucket.com"

  def new_comment_email(service_object)
    @user = service_object.user
    @url  = 'http://www.transbucket.com/pins/' + service_object.commentable.id.to_s
    mail(to: @user.email, subject: 'New Comments on Your Submission')
  end

end
