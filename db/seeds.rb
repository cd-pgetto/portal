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
  IdentityProvider.find_or_create_by!(strategy: strategy) do |idp|
    idp.name = strategy.to_s.titleize
    idp.icon_url = "#{strategy}-icon.jpg"
    idp.availability = "shared"
    idp.client_id = Rails.application.credentials.dig(:omniauth, strategy, :client_id)
    idp.client_secret = Rails.application.credentials.dig(:omniauth, strategy, :client_secret)
  end
end
ap "Seeded IdentityProviders: #{IdentityProvider.all.map(&:name).join(", ")}"

Organization.find_or_create_by!(subdomain: "perceptive") do |org|
  org.name = "Perceptive"
  org.password_auth_allowed = false
  org.identity_providers = [IdentityProvider.find_by(strategy: "google_oauth2", availability: "shared")]
  org.email_domains = [
    EmailDomain.new(domain_name: "perceptive.io"),
    EmailDomain.new(domain_name: "cyberdontics.io"),
    EmailDomain.new(domain_name: "cyberdontics.co")
  ]
end
ap "Seeded Organization: "
ap Organization.find_by(subdomain: "perceptive")
