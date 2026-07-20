Rails.application.routes.draw do
  mount Appkit::Engine => "/"

  namespace :admin do
    root "dashboard#index"
    resources :users
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "appkit/sessions#new"

  resources :users, only: [] do
    resource :profile, only: [ :show, :edit, :update ], controller: "users/profiles"
  end

  namespace :parent do
    resources :children, only: [ :index, :show, :edit, :update ] do
      resource :sticker, only: [ :create ]
      resource :penalty, only: [ :create ]
      resource :reward, only: [ :create ]
      resource :child_profile, only: :update
      resource :avatar, only: :update, controller: "children_avatar"
      get "history", to: "stickers#index"
    end
  end

  namespace :child do
    get "/", to: "dashboard#show", as: :dashboard
  end

  mount ActionCable.server => "/cable"
end
