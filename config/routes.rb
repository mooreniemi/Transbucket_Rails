Transbucket::Application.routes.draw do

  authenticated :user do
    root :to => "pins#index"
  end

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

  match 'contact' => 'contact#new', :as => 'contact', :via => :get
  match 'contact' => 'contact#create', :as => 'contact', :via => :post

  resources :pins do
    resources :pin_images
    resources :flags, :only => [:create]
  end

  match '/pins/:pin_id/flags/remove_flag' => 'flags#destroy', as: 'remove_pin_flag'
  match '/comments/:comment_id/flags/remove_flag' => 'flags#destroy', as: 'remove_comment_flag'

  match 'by_user' => 'pins#by_user', :as => 'by'

  get 'pins' => 'pins#index'
  get 'about' => 'pages#about'
  get 'terms' => 'pages#terms'
  get 'privacy' => 'pages#privacy'
  get 'search_terms' => 'search#search_terms'
  get 'surgeons_only' => 'search#surgeons_only'

  get 'home' => 'pages#home'
  get 'newsfeed' => 'pages#newsfeed'
  get 'admin' => 'pins#admin'

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

end
