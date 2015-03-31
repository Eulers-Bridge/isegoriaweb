Rails.application.routes.draw do

  get 'users/new', to: 'home#signup'
  post 'users/change_access'

  resources :users, only: [:index, :create]

  match '/logout', to: 'sessions#destroy',     via: 'delete'
  match '/login', to: 'sessions#create',     via: 'post'
  resources :sessions, only: [:create, :destroy]
  
  resources :elections, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :events, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :photos, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :articles, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :polls, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :photo_albums, only: [:index]

  # You can have the root of your site routed with "root"
  root 'home#landing'

  get 'home', to: 'home#landing'
  get 'home/more_info'

  get 'home/index'
  get 'home/signup'
  get 'home/unverified_email'
  get 'home/register_successfull'
  get 'home/landing'
  
  get 'error/general_error'

  put 'articles/like/:id(.:format)', :to => 'articles#like', :as => :article_like
  put 'articles/unlike/:id(.:format)', :to => 'articles#unlike', :as => :article_unlike

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
