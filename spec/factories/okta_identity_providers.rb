# == Schema Information
#
# Table name: identity_providers
# Database name: primary
#
#  id            :uuid             not null, primary key
#  availability  :enum             default("shared"), not null
#  client_secret :string           not null
#  icon_url      :string           not null
#  name          :string           not null
#  okta_domain   :string
#  strategy      :string           not null
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string           not null
#
# Indexes
#
#  index_identity_providers_on_strategy                (strategy) UNIQUE WHERE (availability = 'shared'::availability)
#  index_identity_providers_on_strategy_and_client_id  (strategy,client_id) UNIQUE
#  index_identity_providers_on_type                    (type)
#
FactoryBot.define do
  factory :okta_identity_provider, class: "OktaIdentityProvider", parent: :identity_provider do
    name { "Okta" }
    icon_url { "okta-icon.svg" }
    strategy { "okta" }
    availability { "dedicated" }
    okta_domain { "example.okta.com" }
  end
end
