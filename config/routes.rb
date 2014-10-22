Psap::Application.routes.draw do

  root to: redirect('/format-id-guide')
  match '/about', to: 'static#about', via: 'get', as: 'about'
  match '/bibliography', to: 'static#bibliography', via: 'get'
  match '/glossary', to: 'static#glossary', via: 'get'

  # Format ID Guide routes
  match '/format-id-guide', to: 'format_id_guide#index', via: 'get',
        as: 'format_id_guide'
  match '/format-id-guide/search', to: 'format_id_guide#search',
        via: 'get', as: 'format_id_guide_search'
  match '/format-id-guide/:category', to: 'format_id_guide#show',
        via: 'get', as: 'format_id_guide_category'

end
