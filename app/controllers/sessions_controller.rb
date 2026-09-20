# Overrides Devise::SessionsController#new only to send visitors to the
# React login page instead of rendering the old devise/sessions/new.html.erb
# view. Sign-in itself (POST /users/sign_in, i.e. #create) is untouched --
# the React page's form still posts there directly.
#
# A redirect, not a direct render -- the React app is a client-side SPA, so
# the URL in the address bar has to be one its own router actually knows
# about (login_path, i.e. /login) for it to render anything. Rendering the
# same shell directly at /users/sign_in would serve the right HTML/JS, but
# the client-side router has no route registered for that path and shows a
# blank/404 page once it mounts.
class SessionsController < Devise::SessionsController
  def new
    redirect_to login_path
  end
end
