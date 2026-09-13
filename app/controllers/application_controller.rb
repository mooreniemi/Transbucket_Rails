class ApplicationController < ActionController::Base
  SUPPORTED_LOCALES = %w(en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar sv).freeze

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  prepend_before_filter :redirect_legacy_locale
  prepend_before_filter :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource_or_scope)
    pins_path
  end

  def authenticate_user!(*args)
    if request.get? && params[:locale].present? && !user_signed_in?
      return redirect_to new_user_session_path(locale: params[:locale])
    end

    super
  end

  protected

  def set_locale
    requested_locale = params[:locale].presence
    requested_locale = nil unless SUPPORTED_LOCALES.include?(requested_locale)
    saved_locale = session[:locale]
    saved_locale = nil unless SUPPORTED_LOCALES.include?(saved_locale)
    I18n.locale = requested_locale || saved_locale || http_accept_language.compatible_language_from(SUPPORTED_LOCALES) || I18n.default_locale

    capture_user_locale
  end

  # Persists the resolved locale onto the signed-in user's record so
  # background/bulk mailers (which have no request or session to read from)
  # can send in the language they actually use, instead of always English.
  # Only writes when it actually changes, so this isn't a write on every
  # request once it's already in sync.
  #
  # This is a non-essential side effect of every authenticated request (via
  # the prepend_before_filter above), so it must never be able to take a
  # real request down: guards against an unsaved current_user (seen in one
  # controller spec that stubs User.find with a built-not-created record --
  # can't happen with a real Warden session, but cheap to guard anyway) and
  # rescues anything else rather than letting it propagate.
  def capture_user_locale
    return unless user_signed_in?
    return if current_user.new_record?
    return if current_user.locale == I18n.locale.to_s

    current_user.update_column(:locale, I18n.locale.to_s)
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error("capture_user_locale failed for user #{current_user.id}: #{e.message}")
  end

  def redirect_legacy_locale
    return unless request.get?

    path_locale = request.path[%r{\A/(#{SUPPORTED_LOCALES.join('|')})(/|$)}, 1]
    query_locale = request.query_parameters['locale'].to_s
    return if path_locale && query_locale.blank?
    return if path_locale.blank? && query_locale.blank? && params[:locale].present?

    locale = path_locale || (SUPPORTED_LOCALES.include?(query_locale) ? query_locale : 'en')
    localized_path = "/#{locale}#{request.path}"
    localized_path = "/#{locale}/" if request.path == '/'

    query_params = request.query_parameters.dup
    query_params.delete('locale')
    query = query_params.present? ? "?#{Rack::Utils.build_nested_query(query_params)}" : ''
    redirect_to "#{localized_path}#{query}", status: :moved_permanently
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :username, :email, :password, :password_confirmation, :gender_id])
  end

  def default_serializer_options
    { root: false }
  end
end
