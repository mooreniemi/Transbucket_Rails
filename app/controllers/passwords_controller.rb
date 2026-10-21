# Overrides Devise::PasswordsController#new only to send visitors to the
# React forgot password page (see SessionsController for why it's a
# redirect). Changing the password (#edit, #update) is still Devise's own
# server-rendered page.
class PasswordsController < Devise::PasswordsController
  def new
    redirect_to forgot_password_path
  end

  protected

  # JSON requests (the React page) get the same answer whether or not an
  # account has that email: telling them apart would let anyone check which
  # emails are registered. Other errors (a blank email) come back as codes,
  # like sign-up's. HTML requests keep Devise's own behavior.
  def respond_with(*resources, &block)
    resource = resources.first
    # On success Devise passes {} rather than the user.
    if request.format.json? && action_name == 'create'
      if !resource.respond_to?(:errors) || resource.errors.details.dig(:email, 0, :error) == :not_found
        return render json: {
          message: I18n.t('devise.passwords.send_paranoid_instructions'),
          redirect_to: login_path
        }
      end

      return render json: { errors: ErrorCodes.for(resource) }, status: :unprocessable_entity
    end

    super
  end
end
