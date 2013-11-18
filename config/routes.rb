Transbucket::Application.routes.draw do
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


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pins#index'

  # See how all your routes lay out with "rake routes"
end
