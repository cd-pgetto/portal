Rails.application.routes.draw do
  get "home", to: "home#show"
  resources :users
  resource :session
  resources :passwords, param: :token
  namespace :admin do
    resources :organizations
    resources :identity_providers
  end

  root "home#show"

  get "up" => "rails/health#show", :as => :rails_health_check
end
