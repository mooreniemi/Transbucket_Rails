class PreferencesController < ApplicationController
  before_filter :authenticate_user!

  def update
    # The nested user id is only part of the route. Preferences always belong
    # to the signed-in user, never to an id supplied by the browser.
    preference = current_user.preference || current_user.build_preference
    preference.update_attributes!(preference_params)

    redirect_to return_path || edit_user_registration_path
  end

  private

  # The header's safe mode switch sends people back to the page they were on.
  # Only a plain path on this site is accepted, never a URL or a "//host" path.
  def return_path
    path = params[:return_to].to_s
    path if path =~ %r{\A/(?![/\\])[^\s\\]*\z}
  end

  def preference_params
    params.require(:preference).permit(:safe_mode, :notification)
  end
end
