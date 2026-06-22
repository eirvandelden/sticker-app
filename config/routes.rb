Rails.application.routes.draw do
  mount Faultline::Engine, at: "/faultline"

  namespace :admin do
    root "dashboard#index"
    resources :users
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "sessions#new"

  get "session/transfer/:id", to: "sessions/transfers#show", as: :session_transfer
  put "session/transfer/:id", to: "sessions/transfers#update"
  resource :session, only: [ :new, :create, :destroy ]
  resource :preferences, only: [ :edit, :update ]

  namespace :parent do
    resources :children, only: [ :index, :show ] do
      resource :sticker, only: [ :create ]
      resource :penalty, only: [ :create ]
      resource :reward, only: [ :create ]
      get "history", to: "stickers#index"
    end
  end

  namespace :child do
    get "/", to: "dashboard#show", as: :dashboard
  end

  mount ActionCable.server => "/cable"
end
