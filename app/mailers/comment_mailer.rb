class CommentMailer < ActionMailer::Base
  default from: "admin@transbucket.com"

  # about_type is what was commented on: a submission, or a standalone discussion.
  def new_comment_email(receiver_id, about_id, question=false, about_type='Pin')
    @user = User.find(receiver_id)
    @locale = I18n.locale
    url_options = { id: about_id, locale: @locale, host: "www.transbucket.com", protocol: :https }
    @url  = about_type == 'Discussion' ? discussion_url(url_options) : pin_url(url_options)
    @unsub  = edit_user_url(id: receiver_id, locale: @locale, host: "www.transbucket.com", protocol: :https)
    @comment_type = question ? "question" : "comment"
    subject = I18n.t('comment_mailer.subject', comment_type: I18n.t("comment_mailer.types.#{@comment_type}"), id: about_id)
    mail(to: @user.email, subject: subject)
  end
end
