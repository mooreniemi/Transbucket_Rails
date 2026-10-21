Rails.application.routes.draw do
  scope '(:locale)', locale: /en|de|es|fr|it|ja|zh-CN|zh-TW|pt-BR|nl|pl|ru|tr|vi|ar|sv/ do
    root :to => 'pages#home'

    # Devise's old reset password URL, from reset emails that were already
    # sent. Declared before devise_for so it wins. (The old forgot password
    # URL is handled by PasswordsController#new.)
    get "/users/password/edit", to: redirect { |params, req|
      "#{params[:locale] && "/#{params[:locale]}"}/reset-password#{req.query_string.presence && "?#{req.query_string}"}"
    }

    devise_for :users, controllers:{ registrations: "registrations", confirmations: "confirmations", sessions: "sessions", passwords: "passwords" }
    # don't want 404 on requesting users index, it breaks google crawlers
    # if user is signed in, login will actually redirect to pins
    get "/users", to: redirect("/login")

    devise_scope :user do
      # Named so RegistrationsController#new can redirect_to register_path --
      # sign-up itself (POST /users) is untouched.
      get "/register" => "react_app#guest_page", as: "register"
      # Named so SessionsController#new can redirect_to login_path --
      # sign-in itself (POST /users/sign_in) is untouched.
      get "/login" => "react_app#guest_page", as: "login"
      # Named so PasswordsController#new can redirect_to forgot_password_path --
      # requesting the email (POST /users/password) is untouched.
      get "/forgot-password" => "react_app#guest_page", as: "forgot_password"
      # Still Devise's own page, just at a nicer URL -- changing the password
      # (PUT /users/password) is untouched.
      get "/reset-password" => "passwords#edit", as: "reset_password"
    end

    resources :users do
      resource :preferences
    end
    resources :trust_grants, path: 'trust', only: [:index, :create, :destroy]

    resources :comments, :only => [:new, :create, :show, :destroy] do
      resources :flags, :only => [:create]
    end
    resources :discussions, only: [:new, :create, :show, :destroy]
    resources :content_events, only: [:create] do
      collection { post :batch }
    end

    get 'contact' => 'contact#new'
    post 'contact' => 'contact#create'

    # FIXME duplicative
    resources :pin_images
    get 'pins/complication_suggestions' => 'pins#complication_suggestions', as: :complication_suggestions
    resources :pins do
      resources :pin_images
      resources :flags, :only => [:create]
    end

    get 'compare' => 'pages#compare', as: 'compare'
    get 'surgeons/compare' => 'surgeons#compare', as: 'compare_surgeons'
    resources :surgeons
    get 'procedures/compare' => 'procedures#compare', as: 'compare_procedures'
    resources :procedures

    # TODO redundant?
    delete '/pins/:pin_id/flags/remove_flag' => 'flags#destroy', as: 'remove_pin_flag'
    delete '/comments/:comment_id/flags/remove_flag' => 'flags#destroy', as: 'remove_comment_flag'

    get 'by_user' => 'pins#by_user', :as => 'by'
    get 'pins' => 'pins#index'
    get 'queendom' => 'pins#admin'

    get 'about' => 'pages#about'
    get 'terms' => 'pages#terms'
    get 'privacy' => 'pages#privacy'
    get 'home' => 'pages#home'
    get 'newsfeed' => 'pages#newsfeed'

    get 'search_terms' => 'search#search_terms'
    get 'surgeons_only' => 'search#surgeons_only'

    # Identity check for the React app's top-level layout (Header, etc.) --
    # works signed in or out, returns { user: null } rather than a 401 when
    # signed out, since "show a sign-in link" is a valid response too.
    get 'me' => 'current_user#show'

    # reroute for old bookmarks
    get '/members' => 'pages#home'
    get '/therapies' => 'pages#home'
    get '/therapists' => 'pages#home'
    get '/forum' => 'pages#home'
    get '/members/*other' => 'pages#home'
    get '/members/uploads/*other' => 'pages#home'

    # the logs get very noisy with backtraces unless we ignore missing images
    if Rails.env.development?
      get "/system/:url", to: proc { [410, {}, ['']] }, url: /.+/
    end

    # Catch-all for new React-only pages that don't have a Rails route yet.
    # Must stay last: every route above still wins first, so nothing already
    # working here changes. Restricted to HTML so it doesn't swallow
    # requests for a format (json, etc.) nothing above was meant to answer,
    # and to paths that start with a supported locale -- every React route
    # lives under /:locale, and anything else (e.g. /xx/pins) should 404
    # rather than be treated as a page.
    get '*path', to: 'react_app#show',
      constraints: ->(req) { req.format == :html && req.path_parameters[:locale].present? }
  end
end
