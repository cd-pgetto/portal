%w[apple auth0 facebook github linkedin twitter].each do |strategy|
  IdentityProvider.create!(name: strategy.titleize.split.first, strategy: strategy,
    icon_url: "test-icon.svg")
end
ap "Created #{IdentityProvider.count} shared identity providers."

def create_organization
  name = Faker::Company.name
  base_email_domain = name.split(/[ -]/).reject { |el| el == "and" }.take(rand(1..2))
    .join("-").downcase.gsub(/[^a-z0-9-]/, "")
  email_domains = [
    EmailDomain.new(domain_name: base_email_domain + ".com"),
    EmailDomain.new(domain_name: base_email_domain + ".dental")
  ]

  org = Organization.create!(name: name, subdomain: base_email_domain,
    password_auth_allowed: true, email_domains: email_domains)

  use_dedicated = [true, false].sample
  if use_dedicated
    strategy = %w[apple auth0 facebook google_oauth2 github linkedin twitter].sample
    DedicatedIdentityProvider.create!(strategy: strategy, organization: org,
      name: "#{strategy.titleize.split.first} Dedicated", icon_url: "test-icon.svg",
      client_id: Faker::Alphanumeric.alphanumeric(number: 10),
      client_secret: Faker::Alphanumeric.alphanumeric(number: 20))
    org.update!(password_auth_allowed: false)
  else
    shared_providers = IdentityProvider.shared.to_a
    org.update!(password_auth_allowed: [true, false].sample,
      shared_identity_provider_ids: shared_providers.sample(rand(1..shared_providers.count)).map(&:id))
  end
  org
end

def create_practice(organization)
  practice = organization.practices.create!(name: Faker::Address.city)
  user = User.create_with(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name,
    password: "The-quick-brown-fox-8-a-bird!").find_or_create_by!(
      email_address: "owner@#{organization.email_domains.sample.domain_name}"
    )
  practice.members.create!(user:, role: :owner)
  practice.members.create!(user:, role: :admin)
  organization.users << user unless organization.users.include?(user)

  rand(2..5).times do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    user = User.create!(first_name:, last_name:,
      email_address: "#{first_name}.#{last_name.gsub(/[^A-Za-z]/, "")}@#{organization.email_domains.sample.domain_name}",
      password: Faker::Internet.password(min_length: 12))
    practice.members.create!(user:, role: PracticeMember.roles.keys.sample)
    organization.users << user unless organization.users.include?(user)
  end
  practice
end

def create_patient(practice)
  practice.patients.create!(chart_number: Faker::Number.number(digits: 6).to_s)
end

5.times do
  org = create_organization

  rand(1..3).times do
    practice = create_practice(org)

    rand(5..10).times do
      _patient = create_patient(practice)
    end
  end
  dedicated_strategy = org.dedicated_identity_provider&.strategy || "none"
  ap "Created organization #{org.name} using #{dedicated_strategy}, #{org.practices_count} practices, #{org.users.count} members and #{org.practices.joins(:patients).count} patients."
end

# Org using Okta
okta_credentials = Rails.application.credentials.dig(:omniauth, :okta).first
big_dso = Organization.create!(name: "Big DSO", subdomain: "big-dso",
  password_auth_allowed: true,
  email_domains: [
    EmailDomain.new(domain_name: "#{okta_credentials[:name]}.com")
  ])
OktaIdentityProvider.create!(strategy: "okta",
  name: "Okta for Big DSO", icon_url: "okta-icon.svg", okta_domain: okta_credentials[:name],
  client_id: okta_credentials[:client_id], client_secret: okta_credentials[:client_secret],
  organization: big_dso)
big_dso.update!(password_auth_allowed: false)

ap "Total #{Organization.count} organizations with #{Practice.count} practices, #{User.count} members and #{Patient.count} patients."

def tooth_file_name(idx) = "OCTTooth_#{idx}_Y.glb"
def tooth_file_path(idx) = Rails.root.join("test/fixtures/files/", tooth_file_name(idx))

pt = Patient.first
pt.practice.organization.update(password_auth_allowed: true)
dental_model = pt.dental_models.create!(name: "diagnostic - 2025-12-01", model_type: :diagnostic)
maxilla = dental_model.jaws.create!(jaw_type: :maxilla)

[:right, :left].each do |side|
  (1..8).each do |i|
    tooth = maxilla.teeth.create(side: side, number: i)
    tooth_number = tooth.universal_number
    if File.exist?(tooth_file_path(tooth_number))
      tooth.crown_geometry.attach(io: File.open(tooth_file_path(tooth_number)),
        filename: tooth_file_name(tooth_number))
    end
  end
end

ap "Added teeth for patient #{pt.patient_number} in practice #{pt.practice.name} with owner #{pt.practice.first_owner.email_address}"
