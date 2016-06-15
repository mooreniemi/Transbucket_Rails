Rails.application.routes.draw do
  get '/404' => 'errors#not_found'
  get '/422' => 'errors#server_error'
  get '/500' => 'errors#server_error'

  root :to => 'pages#home'

  devise_for :users, :path => 'users'

  devise_scope :user do
    get "/register" => "devise/registrations#new"
    get "/login" => "devise/sessions#new"
  end

  resources :users do
    resource :preferences
  end

  resources :comments, :only => [:create, :destroy] do
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

  get '/pins/:pin_id/flags/remove_flag' => 'flags#destroy', as: 'remove_pin_flag'
  get '/comments/:comment_id/flags/remove_flag' => 'flags#destroy', as: 'remove_comment_flag'

  get 'by_user' => 'pins#by_user', :as => 'by'
  get 'pins' => 'pins#index'
  get 'admin' => 'pins#admin'

  get 'about' => 'pages#about'
  get 'terms' => 'pages#terms'
  get 'privacy' => 'pages#privacy'
  get 'home' => 'pages#home'
  get 'newsfeed' => 'pages#newsfeed'

  get 'search_terms' => 'search#search_terms'
  get 'surgeons_only' => 'search#surgeons_only'

  get 'bookmarks' => 'pages#bookmarks'
  #reroute for old bookmarks
  get '/members' => 'pages#bookmarks'
  get '/therapies' => 'pages#bookmarks'
  get '/surgeons' => 'pages#bookmarks'
  get '/therapists' => 'pages#bookmarks'
  get '/procedures' => 'pages#bookmarks'
  get '/forum' => 'pages#bookmarks'
  get '/members/*other' => 'pages#bookmarks'
  get '/members/uploads/*other' => 'pages#bookmarks'

  # the logs get very noisy with backtraces unless we ignore missing images
  if Rails.env.development?
    get "/system/:url", to: proc { [410, {}, ['']] }, url: /.+/
  end
end
