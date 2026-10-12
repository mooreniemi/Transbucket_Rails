class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters
  before_action :resolve_gender_name, only: :create

  def configure_permitted_parameters
    custom_params = [:name, :username, :gender_id, :pronouns, :pronouns_custom, :email]
    devise_parameter_sanitizer.permit(:account_update, keys: custom_params)
    devise_parameter_sanitizer.permit(:sign_up, keys: custom_params)
  end

  # Sends sign-up links that still use Devise's own route (/users/sign_up)
  # to the React page. Signed-in users are redirected away before this runs
  # (require_no_authentication), and #create is untouched.
  def new
    redirect_to register_path
  end

  protected

  # JSON sign-ups (the React page) get small, predictable bodies: errors keyed
  # by attribute with full messages, or the success message and where to go.
  # HTML sign-ups keep Devise's own behavior.
  def respond_with(*resources, &block)
    resource = resources.first
    if request.format.json? && action_name == 'create' && resource.respond_to?(:errors)
      if resource.errors.any?
        return render json: { errors: resource.errors.to_hash(true) }, status: :unprocessable_entity
      elsif resource.persisted?
        return render json: {
          message: I18n.t('devise.registrations.signed_up_but_unconfirmed'),
          redirect_to: login_path
        }, status: :created
      end
    end

    super
  end

  # The React sign-up form can't know Gender ids (they differ between
  # environments), so it posts the stable Gender#name instead; resolve it to
  # gender_id here. The server-rendered form posts gender_id directly and is
  # unaffected.
  def resolve_gender_name
    return unless params[:user].respond_to?(:key?)

    name = params[:user].delete(:gender).to_s
    return if name.blank? || params[:user][:gender_id].present?

    params[:user][:gender_id] = Gender.where('lower(name) = ?', name.downcase).pick(:id)
  end

  def after_inactive_sign_up_path_for(resource)
    login_path
  end
end
