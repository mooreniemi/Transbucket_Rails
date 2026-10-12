# Devise's failure app, with one change: failures that say the account exists
# but can't be used (not confirmed, locked, disabled) get the same generic
# message as a wrong password. Showing Devise's own wording to someone who may
# be guessing credentials would confirm the account is real.
#
# The login page links to "didn't receive confirmation instructions?" for
# people who need it. Applies to both HTML (flash) and JSON ({ error }) failures.
class AuthFailureApp < Devise::FailureApp
  ACCOUNT_STATE_FAILURES = %i[unconfirmed locked inactive].freeze

  def i18n_message(default = nil)
    if ACCOUNT_STATE_FAILURES.include?(warden_message&.to_sym)
      return I18n.t('devise.failure.invalid', authentication_keys: 'email')
    end

    super
  end

  # JSON failures use the same { errors: { base: [...] } } shape as the
  # sign-up endpoint, so the React forms have one shape to read. `error` is
  # kept for anything that already reads Devise's own key.
  def http_auth_body
    return super unless request_format == :json

    message = i18n_message
    { error: message, errors: { base: [message] } }.to_json
  end
end
