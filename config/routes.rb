Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    skip: [:sessions, :registrations, :passwords]

  devise_scope :user do
    get 'sign_in', :to => 'home#index', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :repositories, except: [:edit, :update] do
    get 'sync'
  end

  resources :transactions

  resources :users, except: [:destroy] do
    get 'sync'
  end

  resources :activities, only: [:index] do
    collection do
      get 'commits'
      get 'activities'
    end
  end

  resources :judging, only: [] do
    collection do
      get 'commits'
      get 'activities'
      post 'rate/:type/:id', action: 'rate', as: :rate
      get 'comments/:type/:id', action: 'comments', as: :comments
      post 'comments/:type/:id', action: 'comment', as: :comment
    end
  end

  namespace :admin do
    resources :repositories do
      member do
        patch :add_judges
        get :assign_judge
      end
    end
    resources :users do
      get 'mark_as_judge'
    end
    resources :judges
    resources :rounds do
      get :mark_as_close
    end
  end

  # get '/subscriptions/:id' => 'subscriptions#subscribe', as: :subscription
  get 'get_new_repos' => "dashboard#get_new_repos"
  get  'dashboard(/:category)', to: 'dashboard#index', as: :dashboard
  post 'score' => 'application#score'
  post 'webhook' => 'dashboard#webhook'
  get 'change_round/:id' => "dashboard#change_round", as: :change_round
  get 'dashboard' => 'dashboard#index'
  get 'leaderboard' => 'dashboard#leaderboard'

  root 'home#index'
end
