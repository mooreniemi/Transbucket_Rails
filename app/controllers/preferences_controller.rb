class PreferencesController < ApplicationController
  before_filter :authenticate_user!

  def update
    # The nested user id is only part of the route. Preferences always belong
    # to the signed-in user, never to an id supplied by the browser.
    preference = current_user.preference || current_user.build_preference
    preference.update_attributes!(preference_params)

    redirect_to edit_user_registration_path
  end

  private

  def preference_params
    params.require(:preference).permit(:safe_mode, :notification)
  end
end
