Psap::Application.routes.draw do
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

  root 'static#landing'
  match '/about', to: 'static#about', via: 'get'
  match '/bibliography', to: 'static#bibliography', via: 'get'
  match '/glossary', to: 'static#glossary', via: 'get'
  match '/help', to: 'static#help', via: 'get'
  # match '/settings', to: 'settings:settings', via: 'get'

  match '/confirm', to: 'users#confirm', via: 'get'
  match '/login', to: 'sessions#new', via: 'get'
  match '/logout', to: 'sessions#destroy', via: 'delete'
  match '/report', to: 'reports#index', via: 'get'

  resources :assessments
  resources :institutions
  resources :locations
  get 'report' => 'report#index'
  resources :repositories
  resources :resources
  resources :roles
  resources :sessions, only: [:new, :create, :destroy]

  # These rules will provide the /users resource, but with /users/new replaced
  # by /register.
  # TODO: this is sloppy:
  # http://blog.teamtreehouse.com/creating-vanity-urls-in-rails
  # http://blog.arkency.com/2014/01/short-urls-for-every-route-in-your-rails-app/
  get '/users/register' => redirect('/register')
  resources :users, path_names: { new: 'register' }
  match '/register', to: 'users#new', via: 'get'

  # Password routes
  # Step 1: "I forgot my password," click a button to POST to /forgot_password
  match '/forgot_password', to: 'password#forgot_password', via: 'get'
  match '/forgot_password', to: 'password#send_email', via: 'post'
  # Step 2: I click the link to /new_password in the email, then POST new
  # password to /new_password
  match '/new_password', to: 'password#new_password', via: 'get'
  match '/new_password', to: 'password#reset_password', via: 'post'

end
