class CommentMailer < ActionMailer::Base
  default from: "admin@transbucket.com"

  def new_comment_email(service_object)
    @user = service_object.commentable_type.constantize.find(service_object.commentable.id).user
    @url  = '#{Rails.root}/pins/#{service_object.commentable_id}'
    mail(to: @user.email, subject: 'New Comments on Your Submission')
  end

end
