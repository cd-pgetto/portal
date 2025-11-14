# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

IdentityProvider.available_strategies.each do |strategy|
  idp = IdentityProvider.find_or_initialize_by(strategy: strategy)
  idp.update(name: strategy.to_s.titleize.split.first, icon_url: "#{strategy.dasherize}-icon.svg",
    availability: "shared",
    client_id: Rails.application.credentials.dig(:omniauth, strategy, :client_id),
    client_secret: Rails.application.credentials.dig(:omniauth, strategy, :client_secret))
  ap idp
end

org = Organization.find_or_initialize_by(subdomain: "perceptive")
org.update(name: "Perceptive", password_auth_allowed: false,
  identity_providers: [IdentityProvider.find_by(strategy: "google_oauth2", availability: "shared")],
  email_domains: [
    EmailDomain.new(domain_name: "perceptive.io"),
    EmailDomain.new(domain_name: "cyberdontics.io"),
    EmailDomain.new(domain_name: "cyberdontics.co")
  ])
ap org
