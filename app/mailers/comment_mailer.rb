class CommentMailer < ActionMailer::Base
  default from: "admin@transbucket.com"

  def new_comment_email(receiver_id, about_id, question=false)
    @user = User.find(receiver_id)
    @url  = pin_url(id: about_id, host: "www.transbucket.com", protocol: :https)
    @unsub  = edit_user_url(id: receiver_id, host: "www.transbucket.com", protocol: :https)
    @comment_type = question ? "question" : "comment"
    subject = "Transbucket.com: New #{@comment_type.titleize} on #{about_id}"
    mail(to: @user.email, subject: subject)
  end
end
