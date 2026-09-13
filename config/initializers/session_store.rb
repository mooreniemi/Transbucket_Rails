# Be sure to restart your server when you modify this file.

session_options = {
  key: '_transbucket_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax
}
cookie_domain = ENV['SESSION_COOKIE_DOMAIN'].to_s
if Rails.env.production? && !cookie_domain.empty?
  # Both production hostnames serve the app. Sharing this cookie prevents a
  # CSRF token issued on one hostname from being rejected on the other.
  session_options.merge!(domain: cookie_domain, secure: true, httponly: true)
end

if Rails::VERSION::MAJOR >= 5
  Rails.application.config.session_store :cookie_store, **session_options
else
  Rails.application.config.session_store :cookie_store, session_options
end
