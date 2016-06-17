class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def configure_permitted_parameters
    custom_params = [:name, :username, :gender_id, :email]
    devise_parameter_sanitizer.for(:account_update).push(*custom_params)
    devise_parameter_sanitizer.for(:sign_up).push(*custom_params)
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    '/users/sign_in'
  end
end
