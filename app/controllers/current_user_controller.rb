# Minimal identity endpoint for the React app's top-level layout (Header,
# etc.) to know whether someone is signed in and who they are. Deliberately
# separate from the fuller profile/settings/submissions data on the account
# page (devise/registrations#edit) -- that's a bigger, page-specific payload
# this has no reason to carry on every request.
class CurrentUserController < ApplicationController
  respond_to :json

  def show
    render json: { user: current_user_json }
  end

  private

  def current_user_json
    return nil unless user_signed_in?

    current_user
      .as_json(only: [:id, :name, :username, :email])
      # Comes from Preference, not the user record itself -- matters on
      # the logged-in home page (whether to show NSFW pins), same policy
      # object PinsController already uses for this.
      .merge(safe_mode: UserPolicy.new(current_user).safe_mode?)
  end
end
