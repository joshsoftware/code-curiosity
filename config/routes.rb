Rails.application.routes.draw do

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    skip: [:sessions, :registrations, :passwords]

  devise_scope :user do
    get 'sign_in', :to => 'home#index', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :repositories, only: [:index, :show] do
    #get 'sync'
  end

  resources :users, except: [:destroy] do
    get 'sync'

    collection do
      get 'set_goal/:goal_id', action: :set_goal, as: 'set_goal'
    end
  end

  resources :activities, only: [:index] do
    collection do
      get 'commits'
      get 'activities'
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
      get 'login_as/:user_id', action: :login_as, on: :collection, as: :login_as
    end
    resources :judges
    resources :rounds do
      get :mark_as_close
    end
    resources :redeem_requests, only: [:index, :update]
  end

  namespace :github do
    get 'repos/sync' => 'repos#sync'
  end

  concern :judgeable do |opts|
    get 'commits', opts
    get 'activities', opts
    get 'comments/:type/:resource_id', opts.merge(action: 'comments', as: :comments)
    post 'comments/:type/:resource_id', opts.merge(action: 'comment', as: :comment)
    post 'rate/:type/:resource_id', opts.merge(action: 'rate', as: :rate_activity)
  end

  resources :judging, only: [] do
    concerns :judgeable, on: :collection
  end

  resources :organizations, only: [:show, :edit, :update] do
    concerns :judgeable, on: :member

    resources :users, only: [:create, :destroy], controller: 'organization/users'
    resources :repositories, only: [:index], controller: 'organization/repositories' do
      collection do
        get :sync
      end
    end
  end

  resources :goals, only: [:index]
  resource :redeem, only: [:create], controller: 'redeem'
  resources :groups

  get 'widgets/repo/:id(/:round_id)' => 'widgets#repo', as: :repo_widget

  get 'change_round/:id' => "dashboard#change_round", as: :change_round
  get 'dashboard' => 'dashboard#index'
  #get 'leaderboard' => 'home#leaderboard'
  get 'trend/(:goal_id)' => 'home#trend', as: :trend

  get 'faq' => 'info#faq'

  root 'home#index'
end
