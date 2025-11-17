# == Schema Information
#
# Table name: organizations
# Database name: primary
#
#  id                    :uuid             not null, primary key
#  name                  :string           not null
#  password_auth_allowed :boolean          default(TRUE), not null
#  subdomain             :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_organizations_on_subdomain  (subdomain) UNIQUE
#
FactoryBot.define do
  sequence(:organization_number) { |n| n }

  factory :organization do
    name { "Organization #{generate(:organization_number)}" }
    subdomain { "org-#{generate(:organization_number)}" }
    password_auth_allowed { true }

    factory :perceptive do
      name { "Perceptive" }
      subdomain { "perceptive" }
      password_auth_allowed { false }
      identity_providers { [IdentityProvider.find_by(strategy: :google_oauth2) || create(:google_identity_provider)] }
      email_domains {
        [create(:perceptive_io_email_domain), create(:cyberdontics_io_email_domain),
          create(:cyberdontics_co_email_domain)]
      }
    end

    factory :big_dso do
      name { "Big DSO" }
      subdomain { "big-dso" }
      password_auth_allowed { false }
      identity_providers {
        [IdentityProvider.find_by(strategy: :google_oauth2) || create(:google_identity_provider),
          create(:identity_provider, availability: "dedicated")]
      }
      email_domains {
        [create(:email_domain, domain_name: "bigdso.com"),
          create(:email_domain, domain_name: "big-dso.com")]
      }
    end
  end
end
