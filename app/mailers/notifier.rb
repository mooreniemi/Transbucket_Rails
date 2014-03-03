class Notifier < ActionMailer::Base
  default :from => 'admin@transbucket.com'

  # send a signup email to the user, pass in the user object that contains the user's email address
  def send_reminder_email(user)
    @user = user
    mail( :to => @user.email,
    :subject => 'Transbucket.com Has Moved' )
  end
end