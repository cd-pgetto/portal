# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

if Rails.env.local?
  IdentityProvider.destroy_all
  Organization.destroy_all
  User.where.not(email_address: "phil@perceptive.io").destroy_all
end

IdentityProvider.available_strategies.each do |strategy|
  next if Rails.application.credentials.dig(:omniauth, strategy.to_sym, :client_id).blank?

  idp = IdentityProvider.find_or_initialize_by(strategy: strategy)
  idp.update(name: strategy.to_s.titleize.split.first, icon_url: "#{strategy.dasherize}-icon.svg",
    availability: "shared",
    client_id: Rails.application.credentials.dig(:omniauth, strategy, :client_id),
    client_secret: Rails.application.credentials.dig(:omniauth, strategy, :client_secret))
end

google_idp = IdentityProvider.find_by(strategy: "google_oauth2", availability: "shared")

org = Organization.find_or_initialize_by(subdomain: "perceptive")
org.update(name: "Perceptive", password_auth_allowed: false,
  identity_providers: [google_idp],
  email_domains: [
    EmailDomain.new(domain_name: "perceptive.io"),
    EmailDomain.new(domain_name: "cyberdontics.io"),
    EmailDomain.new(domain_name: "cyberdontics.co")
  ])

admin_user = User.find_or_initialize_by(email_address: "phil@perceptive.io")
admin_user.update(first_name: "Phil", last_name: "Getto", password: User.random_password)
admin_user.build_organization_membership(organization: org, role: :admin)
admin_user.identities << Identity.new(identity_provider: google_idp, provider_user_id: "107480982343427960619")
admin_user.save!

# standard:disable Rails/Output
ap "Ensured existence of organization #{org.name} with admin user #{admin_user.email_address}."
# standard:enable Rails/Output

if Rails.env.development?
  load Rails.root.join("db/seeds/development.rb")
end
