FactoryBot.define do
  factory :okta_identity_provider, class: "OktaIdentityProvider", parent: :identity_provider do
    name { "Okta" }
    icon_url { "okta-icon.svg" }
    strategy { "okta" }
    organization
    okta_domain { "example" }
  end
end
