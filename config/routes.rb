Rails.application.routes.draw do
  resources :organizations
  # resources :identity_providers

  root "organizations#index"

  get "up" => "rails/health#show", :as => :rails_health_check
end
