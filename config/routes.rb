Rails.application.routes.draw do
  namespace :admin do
    root "dashboard#index"
    resources :users
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "sessions#new"

  get "session/transfer/:id", to: "sessions/transfers#show", as: :session_transfer
  put "session/transfer/:id", to: "sessions/transfers#update"
  resource :session, only: [ :new, :create, :destroy ]
  resource :preferences, only: [ :edit, :update ]

  resources :users, only: [] do
    resource :profile, only: [ :show, :edit, :update ], controller: "users/profiles"
  end

  namespace :parent do
    resources :children, only: [ :index, :show, :edit, :update ] do
      resource :sticker, only: [ :create ]
      resource :penalty, only: [ :create ]
      resource :reward, only: [ :create ]
      resource :child_profile, only: [ :edit, :update ]
      resource :avatar, only: [ :edit, :update ], controller: "children_avatar"
      get "history", to: "stickers#index"
    end
  end

  namespace :child do
    get "/", to: "dashboard#show", as: :dashboard
  end

  mount ActionCable.server => "/cable"
end
