# Because only admin@transbucket.com is verified on SendGrid
# we use it for to and from
class ContactMailer < ActionMailer::Base
  ADMIN = "admin@transbucket.com"
  default :to => ADMIN

  def new_message(message)
    @message = message
    mail(
      :subject => "[Transbucket.com Support] #{message.subject} from #{message.email}",
      :from => ADMIN
    )
  end
end
