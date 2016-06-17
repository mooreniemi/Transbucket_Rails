class UserPolicy
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def wants_email?
    return false if user.nil?
    user.preference.notification == true
  end

  def safe_mode?
    return false if user.nil?
    user.preference.safe_mode == true
  end
end
