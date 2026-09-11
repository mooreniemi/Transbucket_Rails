class ApplicationController < ActionController::Base
  SUPPORTED_LOCALES = %w(en de es fr it ja zh-CN zh-TW pt-BR nl pl ru tr vi ar).freeze

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
