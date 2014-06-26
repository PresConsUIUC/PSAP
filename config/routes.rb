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
  match '/dashboard', to: 'dashboard#index', via: 'get'
  match '/events', to: 'events#index', via: 'get'
  match '/format-id-guide', to: 'format_id_guide#index', via: 'get',
        as: 'format_id_guide'
  match '/glossary', to: 'static#glossary', via: 'get'
  match '/help', to: 'static#help', via: 'get'

  match '/confirm', to: 'users#confirm', via: 'get'
  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  # There is only one assessment template. It can be edited but not deleted,
  # and new ones cannot be created.
  resources :assessments, param: :key, only: [:index, :show] do
    resources :assessment_questions, only: [:new, :create, :edit, :update],
              path: 'assessment-questions'
  end
  resources :assessment_questions, except: [:index, :show],
            path: 'assessment-questions' do
    resources :assessment_question_options, only: :index, path: 'options'
  end
  resources :assessment_sections, except: [:index, :show],
            path: 'assessment-sections' do
    resources :assessment_questions, only: :new, path: 'assessment-questions'
  end
  resources :formats
  resources :institutions do
    resources :repositories, except: :index
    match '/resources/names', to: 'resources#names', via: 'get'
  end
  match '/institutions/:id/report', to: 'institutions#report', via: 'get',
        as: 'institution_report'

  resources :repositories, except: :index do
    resources :locations, except: :index
  end
  resources :locations, except: :index do
    match '/resources/import', to: 'resources#import', via: 'post',
          as: 'resource_import_post'
    resources :resources, except: :index
  end
  resources :resources, except: :index, path_names: { edit: 'assess' } do
    resources :resources, only: [:new, :create]
  end
  #resources :roles # not using this at the moment
  resources :sessions, only: [:new, :create, :destroy]

  # These rules will provide the /users resource, but with /users/new replaced
  # by /register.
  # TODO: eliminate /users/register
  get '/users/register' => redirect('/register')
  resources :users, param: :username, path_names: { new: 'register' }
  match '/register', to: 'users#new', via: 'get'
  match '/users/:username/enable', to: 'users#enable', via: 'patch', as: 'enable_user'
  match '/users/:username/disable', to: 'users#disable', via: 'patch', as: 'disable_user'
  match '/users/:username/exists', to: 'users#exists', via: 'get', as: 'user_exists'
  match '/users/:username/reset_feed_key', to: 'users#reset_feed_key', via: 'patch', as: 'reset_user_feed_key'

  # Password routes
  # Step 1: "I forgot my password," click a button to POST to /forgot_password
  match '/forgot_password', to: 'password#forgot_password', via: 'get'
  match '/forgot_password', to: 'password#send_email', via: 'post'
  # Step 2: I click the link to /new_password in the email, then POST new
  # password to /new_password
  match '/new_password', to: 'password#new_password', via: 'get'
  match '/new_password', to: 'password#reset_password', via: 'post'

end
