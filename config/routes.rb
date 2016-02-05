Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    skip: [:sessions, :registrations, :passwords]

  devise_scope :user do
    get 'sign_in', :to => 'home#index', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :repositories do
    get 'sync'
  end

  resources :transactions

  resources :users do
    get 'mark_as_judge'
    get 'sync'
  end

  get '/subscriptions/:id' => 'subscriptions#subscribe', as: :subscription 
  get 'get_new_repos' => "dashboard#get_new_repos"
  get  'dashboard(/:category)', to: 'dashboard#index', as: :dashboard
  post 'score' => 'application#score'
  post 'webhook' => 'dashboard#webhook'
  post 'take_snapshot' => "dashboard#take_snapshot"
  post 'change_round' => "dashboard#change_round"
  get 'dashboard' => 'dashboard#index'

  root 'home#index'
end
