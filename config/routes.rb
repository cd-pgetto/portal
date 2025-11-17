Rails.application.routes.draw do
  get "home", to: "home#show"

  # OAuth routes
  get "/oauth/:provider/callback", to: "identities#create"
  post "/oauth/:provider/callback", to: "identities#create"
  get "/oauth/failure", to: "identities#failure"

  resource :session, only: [:new, :create, :destroy]
  resources :users, only: [:show, :new, :create, :edit, :update]
  resources :passwords, param: :token

  namespace :admin do
    resource :dashboard, only: [:show]
    resources :organizations
    resources :identity_providers
  end

  root "home#show"

  get "up" => "rails/health#show", :as => :rails_health_check
end
