# Overrides Devise::PasswordsController#new only to send visitors to the
# React forgot password page (see SessionsController for why it's a
# redirect). The reset page the email links to is React too, at
# /reset-password (Devise's own /users/password/edit redirects there in
# config/routes.rb). Requesting the email (#create) and changing the password
# (#update) are Devise's own.
class PasswordsController < Devise::PasswordsController
  def new
    redirect_to forgot_password_path
  end

  protected

  # JSON requests (the React pages) get small, predictable bodies, like
  # sign-up's. HTML requests keep Devise's own behavior.
  def respond_with(*resources, &block)
    resource = resources.first
    return super unless request.format.json?

    case action_name
    when 'create' then respond_to_reset_request
    when 'update' then respond_to_password_change(resource)
    else super
    end
  end

  private

  # Always the same answer, whatever the email: Devise is paranoid (see
  # config/initializers/devise.rb), so #create always takes its success path.
  def respond_to_reset_request
    render json: {
      message: I18n.t('devise.passwords.send_paranoid_instructions'),
      redirect_to: login_path
    }
  end

  # An invalid or expired link comes back as an error on reset_password_token,
  # password problems as errors on password / password_confirmation. On
  # success Devise has signed the user in, so send them where signing in would.
  def respond_to_password_change(resource)
    if resource.errors.any?
      return render json: { errors: ErrorCodes.for(resource) }, status: :unprocessable_entity
    end

    signed_in = user_signed_in?
    render json: {
      message: I18n.t(signed_in ? 'devise.passwords.updated' : 'devise.passwords.updated_not_active'),
      redirect_to: signed_in ? after_sign_in_path_for(resource) : login_path
    }
  end
end
