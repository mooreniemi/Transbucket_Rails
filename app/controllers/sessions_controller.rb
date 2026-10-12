# Overrides Devise::SessionsController#new only to send visitors to the
# React login page instead of rendering the old devise/sessions/new.html.erb
# view. Sign-in itself (POST /users/sign_in, i.e. #create) is Devise's own;
# the React page posts JSON to it (see react/src/lib/api.ts).
#
# A redirect, not a direct render -- the React app is a client-side SPA, so
# the URL in the address bar has to be one its own router actually knows
# about (login_path, i.e. /login) for it to render anything.
class SessionsController < Devise::SessionsController
  def new
    redirect_to login_path
  end

  # JSON sign-ins answer with only where to go next. Devise would otherwise
  # serialize the whole user. Failures never get here: they come from
  # AuthFailureApp as a 401 { error }.
  def create
    super do |resource|
      if request.format.json?
        return render json: { redirect_to: after_sign_in_path_for(resource) }
      end
    end
  end
end
