FactoryBot.define do
  sequence(:organization_number) { |n| n }

  factory :organization do
    name { "Organization #{generate(:organization_number)}" }
    subdomain { "org-#{generate(:organization_number)}" }
    password_auth_allowed { true }

    factory :perceptive do
      name { "Perceptive" }
      subdomain { "perceptive" }
      password_auth_allowed { true }
      email_domains {
        [create(:perceptive_io_email_domain), create(:cyberdontics_io_email_domain),
          create(:cyberdontics_co_email_domain)]
      }
      after(:create) do |org|
        google_idp = IdentityProvider.find_by(strategy: :google_oauth2) || create(:google_identity_provider)
        org.shared_identity_providers << google_idp
        org.update!(password_auth_allowed: false)
      end
    end

    factory :big_dso do
      name { "Big DSO" }
      subdomain { "big-dso" }
      password_auth_allowed { true }
      email_domains {
        [create(:email_domain, domain_name: "bigdso.com"),
          create(:email_domain, domain_name: "big-dso.com")]
      }
      after(:create) do |org|
        create(:okta_identity_provider, organization: org, client_id: "big-dso-okta-client-id")
        org.reload.update!(password_auth_allowed: false)
      end
    end
  end
end
