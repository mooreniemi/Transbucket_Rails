class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update).push(:name, :username, :gender_id, :email)
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    '/users/sign_in'
  end
end
