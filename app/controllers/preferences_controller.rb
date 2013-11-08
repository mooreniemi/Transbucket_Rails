class PreferencesController < ApplicationController
  def update
    user = User.find(params[:user_id])
    preference = Preference.find_by_user_id(user.id)

    preference.safe_mode = true if params[:preference]["safe_mode"] == "1"
    preference.notification = true if params[:preference]["notification"] == "1"

    preference.safe_mode = false if params[:preference]["safe_mode"] == "0"
    preference.notification = false if params[:preference]["notification"] == "0"

    preference.save!

    redirect_to edit_user_registration_path
  end
end
