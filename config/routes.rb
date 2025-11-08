Rails.application.routes.draw do
  namespace :admin do
    resources :organizations
    # resources :identity_providers
  end

  root "admin/organizations#index"

  get "up" => "rails/health#show", :as => :rails_health_check
end
