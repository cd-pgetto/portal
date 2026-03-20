Rails.application.routes.draw do
  resources :patients
  resources :practices, only: [:index, :show, :edit, :update] do
    post :select, on: :member
    resources :invitations, module: :practice, only: [:create, :destroy]
    resources :memberships, module: :practice, only: [:create, :destroy]
  end
  resources :invitations, only: [:show], param: :token do
    patch :accept, on: :member
  end

  # OAuth routes
  get "/oauth/:provider/callback", to: "identities#create"
  post "/oauth/:provider/callback", to: "identities#create"
  get "/oauth/failure", to: "identities#failure"

  resource :session, only: [:new, :create, :destroy]
  resources :users, only: [:show, :new, :create, :edit, :update]
  resources :passwords, param: :token

  namespace :graphical do
    resources :dental_models, only: [:show]
  end

  namespace :admin do
    resources :users
    resource :dashboard, only: [:show]
    resources :organizations do
      resources :practices
    end
    resources :practices
    resources :identity_providers
  end

  get "home", to: "home#show"
  root "home#show"

  get "up" => "rails/health#show", :as => :rails_health_check
end
