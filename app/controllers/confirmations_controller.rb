# Overrides Devise::ConfirmationsController#show only to sign the user in
# immediately after a successful confirmation, rather than dropping them at
# the sign-in page. Someone confirming an account they signed up for months
# or years ago (the exact audience of the reminder campaign) is unlikely to
# still remember their password, so making them log in right after
# confirming was an unnecessary second point of failure.
class ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      sign_in(resource_name, resource)
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  protected

  def after_confirmation_path_for(resource_name, resource)
    signed_in?(resource_name) ? after_sign_in_path_for(resource) : new_session_path(resource_name)
  end
end
