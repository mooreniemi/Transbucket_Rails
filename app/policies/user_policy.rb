class UserPolicy
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def wants_email?
    user.preference && (user.preference.notification == true)
  end

  def safe_mode?
    user.preference && (user.preference.safe_mode == true)
  end
end
