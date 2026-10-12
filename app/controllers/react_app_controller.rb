class ReactAppController < ApplicationController
  layout 'react_app'

  before_action :redirect_signed_in_users, only: :guest_page

  def show
  end

  # The login and register pages: nothing to do for someone who is already
  # signed in, so send them where signing in would have (what Devise's
  # require_no_authentication did for the old server-rendered pages).
  def guest_page
    render :show
  end

  private

  def redirect_signed_in_users
    redirect_to after_sign_in_path_for(current_user) if user_signed_in?
  end
end
