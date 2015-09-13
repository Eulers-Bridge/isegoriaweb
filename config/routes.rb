Rails.application.routes.draw do
  
  match '/logout', to: 'sessions#destroy',     via: 'delete'
  match '/login', to: 'sessions#create',     via: 'post'

  resources :sessions, only: [:create, :destroy]
  resources :users, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :elections, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :events, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :photos, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :articles, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :polls, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :photo_albums, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :positions, only: [:create, :update, :destroy, :index]
  resources :tickets, only: [:create, :update, :destroy, :new, :edit, :index]
  resources :candidates, only: [:create, :update, :destroy, :new, :edit, :index]

  # You can have the root of your site routed with "root"
  root 'home#landing'
  #root 'home#index'

  get 'home', to: 'home#landing'
  get 'home/more_info'
  get 'home/signup'
  get 'home/details'
  get 'home/unverified_email'
  get 'home/register_successfull'
  get 'home/landing'
  
  get 'error/general_error'
  
  post 'home/signup_user', :to => 'home#signup_user', :as => :home_signup_user
  put 'user/resend_verification_email/:id(.:format)', :to => 'user#resend_verification_email', :as => :user_resend_verification_email
  post 'articles/picture/:id(.:format)', :to => 'articles#upload_picture', :as => :article_upload_picture
  delete 'articles/picture/:id(.:format)', :to => 'articles#delete_picture', :as => :article_delete_picture
  post 'events/picture/:id(.:format)', :to => 'events#upload_picture', :as => :event_upload_picture
  delete 'events/picture/:id(.:format)', :to => 'events#delete_picture', :as => :event_delete_picture
  post 'photo_albums/picture/:id(.:format)', :to => 'photo_albums#upload_picture', :as => :photo_album_upload_picture
  delete 'photo_albums/picture/:id(.:format)', :to => 'photo_albums#delete_picture', :as => :photo_album_delete_picture

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
