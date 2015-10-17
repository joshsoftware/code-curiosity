Rails.application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  resources :teams
  get 'repositories' => "dashboard#repositories"
  post 'index' => "dashboard#index"
  get 'widget/team' => "dashboard#team"
  get 'widget/individual' => "dashboard#individual"

  post 'score' => 'application#score'

  root 'dashboard#index'


end
