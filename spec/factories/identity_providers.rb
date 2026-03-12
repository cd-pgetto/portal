FactoryBot.define do
  sequence(:identity_provider_number) { |n| n }

  factory :identity_provider do
    name { "IdP-#{generate(:identity_provider_number)}" }
    icon_url { "test-icon.svg" }
    strategy { "strategy-#{generate(:identity_provider_number)}" }
    client_id { "client_id-#{generate(:identity_provider_number)}" }
    client_secret { "SuperSekret" }

    factory :google_identity_provider do
      name { "Google OAuth" }
      icon_url { "google-oauth2-icon.svg" }
      strategy { "google_oauth2" }
      client_id { "google-client-id" }
      client_secret { "GoogleSuperSekret" }
    end
  end
end
