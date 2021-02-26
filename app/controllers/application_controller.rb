class ApplicationController < ActionController::Base
  include HttpAcceptLanguage::AutoLocale

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource_or_scope)
    '/pins'
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :username, :email, :password, :password_confirmation, :gender_id)
    end
  end

  def default_serializer_options
    { root: false }
  end
end
