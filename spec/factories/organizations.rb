# == Schema Information
#
# Table name: organizations
#
#  id                   :uuid             not null, primary key
#  allows_password_auth :boolean          default(TRUE), not null
#  name                 :string           not null
#  subdomain            :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
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
    allows_password_auth { true }

    factory :perceptive do
      name { "Perceptive" }
      subdomain { "perceptive" }
      allows_password_auth { false }
      after(:create) do |organization|
        # organization.email_domains << create(:perceptive_io_email_domain)
        # organization.email_domains << create(:cyberdontics_io_email_domain)
        # organization.email_domains << create(:cyberdontics_co_email_domain)
        organization.identity_providers << create(:google_identity_provider)
      end
    end

    factory :big_dso do
      name { "Big DSO" }
      subdomain { "big-dso" }
      allows_password_auth { false }
      after(:create) do |organization|
        # organization.email_domains << create(:email_domain, domain_name: "bigdso.com")
        # organization.email_domains << create(:email_domain, domain_name: "big_dso.com")
        organization.identity_providers << create(:google_identity_provider)
      end
    end
  end
end
