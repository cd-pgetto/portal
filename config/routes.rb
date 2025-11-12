Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  namespace :admin do
    resources :organizations
    resources :identity_providers
  end

  root "admin/organizations#index"

  get "up" => "rails/health#show", :as => :rails_health_check
end
