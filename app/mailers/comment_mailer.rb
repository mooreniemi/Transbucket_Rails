class CommentMailer < ActionMailer::Base
  default from: "admin@transbucket.com"

  def new_comment_email(receiver_id, about_id, question=false)
    @user = User.find(receiver_id)
    @locale = I18n.locale
    @url  = pin_url(id: about_id, locale: @locale, host: "www.transbucket.com", protocol: :https)
    @unsub  = edit_user_url(id: receiver_id, locale: @locale, host: "www.transbucket.com", protocol: :https)
    @comment_type = question ? "question" : "comment"
    subject = I18n.t('comment_mailer.subject', comment_type: I18n.t("comment_mailer.types.#{@comment_type}"), id: about_id)
    mail(to: @user.email, subject: subject)
  end
end
