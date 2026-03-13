# == Schema Information
#
# Table name: identity_providers
# Database name: primary
#
#  id              :uuid             not null, primary key
#  client_secret   :text             default("")
#  icon_url        :string           not null
#  name            :string           not null
#  okta_domain     :string
#  strategy        :string           not null
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :text             default("")
#  organization_id :uuid
#
# Indexes
#
#  index_identity_providers_on_organization_id  (organization_id) UNIQUE WHERE (organization_id IS NOT NULL)
#  index_identity_providers_on_strategy         (strategy) UNIQUE WHERE (organization_id IS NULL)
#  index_identity_providers_on_type             (type)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
FactoryBot.define do
  sequence(:identity_provider_number) { |n| n }

  factory :identity_provider, class: "IdentityProvider::Shared" do
    name { "IdP-#{generate(:identity_provider_number)}" }
    icon_url { "test-icon.svg" }
    strategy { "strategy-#{generate(:identity_provider_number)}" }

    factory :google_identity_provider do
      name { "Google OAuth" }
      icon_url { "google-oauth2-icon.svg" }
      strategy { "google_oauth2" }
    end
  end
end
