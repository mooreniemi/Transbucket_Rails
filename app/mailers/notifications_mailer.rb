class NotificationsMailer < ActionMailer::Base

  default :from => :email
  default :to => "admin@transbucket.com"

  def new_message(message)
    @message = message
    mail(:subject => "[Transbucket.com Support] #{message.subject}")
  end

end