Psap::Application.routes.draw do

  root 'static#landing'
  match '/about', to: 'static#about', via: 'get', as: 'about'
  match '/bibliography', to: 'static#bibliography', via: 'get'
  match '/dashboard', to: 'dashboard#index', via: 'get'
  match '/events', to: 'events#index', via: 'get'
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
    match '/assessment-report', to: 'institutions#assessment_report', via: 'get'
    resources :repositories, except: :index
    match '/assessment-questions', to: 'assessment_questions#index', via: 'get'
    match '/events', to: 'institutions#events', via: 'get'
    match '/info', to: 'institutions#info', via: 'get'
    match '/repositories', to: 'institutions#repositories', via: 'get'
    match '/resources', to: 'institutions#resources', via: 'get'
    match '/users', to: 'institutions#users', via: 'get'
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
  match '/resources/move', to: 'resources#move', via: 'post', as: 'resource_move'
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

  # Format ID Guide routes
  match '/format-id-guide', to: 'format_id_guide#index', via: 'get',
        as: 'format_id_guide'
  match '/format-id-guide/search', to: 'format_id_guide#search',
        via: 'get', as: 'format_id_guide_search'
  match '/format-id-guide/:category', to: 'format_id_guide#show',
        via: 'get', as: 'format_id_guide_category'

  # Advanced Help routes
  match '/help', to: 'help#index', via: 'get', as: 'help'
  match '/help/:category', to: 'help#show', via: 'get', as: 'help_category'

  # User Manual routes
  match '/manual', to: 'user_manual#index', via: 'get', as: 'user_manual'
  match '/manual/:category', to: 'user_manual#show', via: 'get',
        as: 'user_manual_category'
end
