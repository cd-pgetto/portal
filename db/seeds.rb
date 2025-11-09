# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# name { "Google OAuth" }
# icon_url { "google-icon.jpg" }
# strategy { "google_oauth2" }
# availability { "shared" }
# client_id { "google-client-id" }
# client_secret { "GoogleSuperSekret" }

unless IdentityProvider.exists?(strategy: "google_oauth2")
  IdentityProvider.create_with(name: "Google OAuth", icon_url: "google-icon.jpg", availability: "shared",
    client_id: "google-client-id", client_secret: "GoogleSuperSekret").find_or_create_by!(strategy: "google_oauth2")
end

unless IdentityProvider.exists?(strategy: "microsoft")
  IdentityProvider.create_with(name: "Microsoft", icon_url: "microsoft-icon.jpg", availability: "shared",
    client_id: "microsoft-client-id", client_secret: "microsoftSuperSekret").find_or_create_by!(strategy: "microsoft")
end

unless IdentityProvider.exists?(strategy: "github")
  IdentityProvider.create_with(name: "GitHub", icon_url: "github-icon.jpg", availability: "shared",
    client_id: "github-client-id", client_secret: "githubSuperSekret").find_or_create_by!(strategy: "github")
end

unless IdentityProvider.exists?(strategy: "twitter")
  IdentityProvider.create_with(name: "Twitter", icon_url: "twitter-icon.jpg", availability: "shared",
    client_id: "twitter-client-id", client_secret: "TwitterSuperSekret").find_or_create_by!(strategy: "twitter")
end

unless IdentityProvider.exists?(strategy: "facebook")
  IdentityProvider.create_with(name: "Facebook", icon_url: "facebook-icon.jpg", availability: "shared",
    client_id: "facebook-client-id", client_secret: "FacebookSuperSekret").find_or_create_by!(strategy: "facebook")
end
