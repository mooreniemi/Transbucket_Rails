Rails.application.routes.draw do
  root :to => 'pages#home'

  devise_for :users, controllers: { registrations: "registrations" }
  # don't want 404 on requesting users index, it breaks google crawlers
  # if user is signed in, login will actually redirect to pins
  get "/users", to: redirect("/login")

  devise_scope :user do
    get "/register" => "devise/registrations#new"
    get "/login" => "devise/sessions#new"
  end

  resources :users do
    resource :preferences
  end

  resources :comments, :only => [:new, :create, :destroy] do
    resources :flags, :only => [:create]
  end

  get 'contact' => 'contact#new'
  post 'contact' => 'contact#create'

  # FIXME duplicative
  resources :pin_images
  resources :pins do
    resources :pin_images
    resources :flags, :only => [:create]
  end

  resources :surgeons
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
end
