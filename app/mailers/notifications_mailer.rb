class NotificationsMailer < ActionMailer::Base

  default :to => "admin@transbucket.com"

  def new_message(message)
    @message = message
    mail(:subject => "[Transbucket.com Support] #{message.subject}", :from => message.email)
  end

end