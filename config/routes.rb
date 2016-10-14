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
  match '/about', to: 'static#about', via: 'get', as: 'about'
  match '/assessment-report', to: 'assessment_report#index', via: 'get',
        as: 'assessment_report'
  match '/bibliography', to: 'static#bibliography', via: 'get'
  match '/dashboard', to: 'dashboard#index', via: 'get'
  match '/events', to: 'events#index', via: 'get'
  match '/getting-started', to: 'static#getting_started', via: 'get'
  match '/glossary', to: 'static#glossary', via: 'get'

  match '/signin', to: 'sessions#new', via: 'get'
  match '/signout', to: 'sessions#destroy', via: 'delete'

  resources :formats, only: [:index, :show] do
    # used for populating the new/edit resource form with assessment questions
    resources :assessment_questions, only: :index, path: 'assessment-questions'
  end
  # used for dependent select menus in forms
  resources :format_classes, only: [], path: 'format-classes' do
    resources :formats, only: :index, path: 'formats'
  end
  resources :institutions do
    match '/assess', to: 'institutions#assess', via: 'get'
    resources :repositories, except: :index
    match '/assessment-questions', to: 'assessment_questions#index', via: 'get'
    # these are used for form autocompletion
    match '/resources/names', to: 'resources#names', via: 'get'
    match '/resources/subjects', to: 'resources#subjects', via: 'get'
  end
  match '/institutions/:id/report', to: 'institutions#report', via: 'get',
        as: 'institution_report'

  resources :repositories, except: :index do
    resources :locations, except: :index
  end
  resources :locations, except: :index do
    match '/assess', to: 'locations#assess', via: 'get'
    match '/resources/import', to: 'resources#import', via: 'post',
          as: 'resource_import_post'
    match '/assessment-questions', to: 'assessment_questions#index', via: 'get'
    resources :resources, except: :index
  end
  match '/resources/move', to: 'resources#move', via: 'post',
        as: 'resource_move'
  match '/resources/search', to: 'resources#search', via: 'get',
        as: 'resource_search'
  resources :resources, except: :index do
    match '/assess', to: 'resources#assess', via: 'get'
    match '/clone', to: 'resources#clone', via: 'patch', as: 'resource_clone'
    match '/import', to: 'resources#import', via: 'post', as: 'import_post'
    resources :resources, only: [:new, :create]
  end
  resources :sessions, only: [:new, :create, :destroy]

  resources :users, param: :username, path_names: { new: 'register' }
  match '/users/:username/confirm', to: 'users#confirm',
        via: 'get', as: 'confirm_user'
  match '/users/:username/enable', to: 'users#enable',
        via: 'patch', as: 'enable_user'
  match '/users/:username/disable', to: 'users#disable',
        via: 'patch', as: 'disable_user'
  match '/users/:username/exists', to: 'users#exists',
        via: 'get', as: 'user_exists'
  match '/users/:username/reset_feed_key', to: 'users#reset_feed_key',
        via: 'patch', as: 'reset_user_feed_key'
  match '/users/:username/approve-institution', to: 'users#approve_institution',
        via: 'patch', as: 'approve_user_institution'
  match '/users/:username/refuse-institution', to: 'users#refuse_institution',
        via: 'patch', as: 'refuse_user_institution'

  # Password routes
  # Step 1: "I forgot my password," click a button to POST to /forgot-password
  match '/forgot-password', to: 'password#forgot_password', via: 'get'
  match '/forgot-password', to: 'password#send_email', via: 'post'
  # Step 2: I click the link to /new-password in the email, then POST new
  # password to /new-password
  match '/new-password', to: 'password#new_password', via: 'get'
  match '/new-password', to: 'password#reset_password', via: 'post'

  # Collection ID Guide (formerly Format ID Guide) routes
  match '/collection-id-guide', to: 'format_id_guide#index', via: 'get',
        as: 'format_id_guide'
  match '/collection-id-guide/search', to: 'format_id_guide#search',
        via: 'get', as: 'format_id_guide_search'
  match '/collection-id-guide/:category', to: 'format_id_guide#show',
        via: 'get', as: 'format_id_guide_category'

  # Redirect old Format ID Guide paths to Collection ID Guide paths
  get '/format-id-guide', to: redirect('/collection-id-guide')
  get '/format-id-guide/search', to: redirect('/collection-id-guide/search')
  get '/format-id-guide/:category', to: redirect('/collection-id-guide/:category')

  # Help routes
  match '/help', to: 'help#index', via: 'get', as: 'help'
  match '/help/search', to: 'help#search', via: 'get', as: 'help_search'
  match '/simple-help', to: 'help#simple_index', via: 'get', as: 'simple_help'
  match '/advanced-help', to: 'help#advanced_index', via: 'get',
        as: 'advanced_help'
  match '/advanced-help/:category', to: 'help#advanced_show', via: 'get',
        as: 'advanced_help_category'
  match '/manual', to: 'help#manual', via: 'get', as: 'user_manual'

end
