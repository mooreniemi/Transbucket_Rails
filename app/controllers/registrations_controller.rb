class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def configure_permitted_parameters
    custom_params = [:name, :username, :gender_id, :email]
    devise_parameter_sanitizer.permit(:account_update, keys: custom_params)
    devise_parameter_sanitizer.permit(:sign_up, keys: custom_params)
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    '/users/sign_in'
  end
end
