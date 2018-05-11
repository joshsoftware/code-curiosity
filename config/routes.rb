require 'sidekiq/web'
require 'sidekiq-status/web'

Rails.application.routes.draw do

  Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

  api_version('module': 'V1', header: {name: 'Accept', value: 'application/vnd.codecuriosity.org; version=1'}) do
    resources :transactions, only: [:index]
    resources :subscriptions, only: [:index]
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' },
    skip: [:sessions, :registrations, :passwords]

  devise_scope :user do
    get 'sign_in', :to => 'home#index', :as => :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :repositories, only: [:index]

  resources :sponsorer_details do
    member do
      post 'update_card'
      get 'cancel_subscription'
    end
  end

  post "/stripe/webhooks", to: "stripe#webhooks"

  resources :users, only: [:index, :show, :destroy, :edit, :update] do
    member do
      patch :remove_handle
      get 'sync'
      put 'update_notification'
    end

    collection do
      get 'search'
    end
  end

  resources :activities, only: [:index] do
    collection do
      get 'commits'
      get 'activities'
    end
  end

  namespace :admin do
    resources :repositories, only: [:index] do
      get :search, on: :collection
      member do
        patch :update_ignore_field
      end
    end
    resources :users, only: [:index, :destroy] do
      get :login_as
      get :search, on: :collection
      member do
        patch :block_user
      end
    end

    resources :rounds, only: [:index] do
      get :mark_as_close
    end

    resources :redeem_requests, only: [:index, :update, :destroy] do
      collection do
        get :download
      end
    end

    resources :ignored_files, except: [:show] do
      get :search, on: :collection
      patch :update_ignore_field
    end

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

  resource :redeem, only: [:create], controller: 'redeem'
  resources :groups do
    member do
      patch :feature
    end
    resources :members, only: [:index, :create, :destroy], controller: 'groups/members' do
      delete :destroy_invitation
      get :resend_invitation
    end
  end
  get 'accept_invitation/:group_id/:token' => 'groups/members#accept_invitation', as: :accept_invitation
  get 'widgets/repo/:id(/:round_id)' => 'widgets#repo', as: :repo_widget
  get 'widgets/group/:id(/:round_id)' => 'widgets#group', as: :group_widget

  get 'change_round/:id' => "dashboard#change_round", as: :change_round
  get 'dashboard' => 'dashboard#index'
  #get 'leaderboard' => 'home#leaderboard'

  get 'faq' => 'info#faq'

  root 'home#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
