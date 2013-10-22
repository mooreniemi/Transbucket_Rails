Transbucket::Application.routes.draw do

  resources :pins
  devise_for :users
  resources :comments, :only => [:create, :destroy]

  match 'contact' => 'contact#new', :as => 'contact', :via => :get
  match 'contact' => 'contact#create', :as => 'contact', :via => :post

  devise_scope :user do
  get "/register" => "devise/registrations#new"
  get "/login" => "devise/sessions#new"
end

resources :pin do
      resources :pin_images
  end

root :to => 'pins#index'
  get 'pins' => 'pins#index'
  get 'about' => 'pages#about'
  get 'terms' => 'pages#terms'
  get 'privacy' => 'pages#privacy'

  get 'home' => 'pages#home'
  get 'admin' => 'pins#admin'

  get '/:type/:id/flag', to: 'flags#create'
  get '/:type/:id/remove_flag', to: 'flags#remove_flag'

  #reroute for old bookmarks
  get '/members' => 'pages#update'
  get '/therapies' => 'pages#update'
  get '/surgeons' => 'pages#update'
  get '/therapists' => 'pages#update'
  get '/members' => 'pages#update'
  get '/procedures' => 'pages#update'
  get '/members/therapies' => 'pages#update'
  get '/members/surgeons' => 'pages#update'
  get '/members/therapists' => 'pages#update'
  get '/members/procedures' => 'pages#update'
  get '/members/galleries' => 'pages#update'
  get '/members/uploads' => 'pages#update'
  get '/members/index.php' => 'pages#update'
  get '/members/galleries/processForm.php' => 'pages#update'
  get '/forum' => 'pages#update'

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
