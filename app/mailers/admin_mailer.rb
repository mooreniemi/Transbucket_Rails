class AdminMailer < ActionMailer::Base
   default from: "admin@transbucket.com"

  def announcement_email(user)
  	@user = user
  	@url = edit_user_registration_url
    mail(:to => @user.email,
    :subject => 'Announcements from Transbucket.com')
  end
end
