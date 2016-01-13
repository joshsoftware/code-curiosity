Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations', :omniauth_callbacks => "users/omniauth_callbacks" }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  resources :teams
  resources :repositories do
    get 'sync'
  end
  resources :users do
    get 'mark_as_judge'
    get 'sync'
  end
  
  get 'get_new_repos' => "dashboard#get_new_repos"
  get  'dashboard(/:category)', to: 'dashboard#index', as: :dashboard
  post 'score' => 'application#score'
  post 'webhook' => 'dashboard#webhook'
  post 'take_snapshot' => "dashboard#take_snapshot"
  post 'change_round' => "dashboard#change_round"
  root 'dashboard#index'


end
