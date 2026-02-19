Rails.application.routes.draw do
  mount Faultline::Engine, at: "/faultline"
  get "up" => "rails/health#show", as: :rails_health_check

  root "sessions#new"

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
