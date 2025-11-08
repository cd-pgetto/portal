# == Schema Information
#
# Table name: identity_providers
#
#  id            :uuid             not null, primary key
#  availability  :enum             default("shared"), not null
#  client_secret :string           not null
#  icon_url      :string           not null
#  name          :string           not null
#  strategy      :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string           not null
#
# Indexes
#
#  index_identity_providers_on_strategy                (strategy) UNIQUE WHERE (availability = 'shared'::availability)
#  index_identity_providers_on_strategy_and_client_id  (strategy,client_id) UNIQUE
#
FactoryBot.define do
  sequence(:identity_provider_number) { |n| n }

  factory :identity_provider do
    name { "IdP-#{generate(:identity_provider_number)}" }
    icon_url { "#{name}-icon.jpg" }
    strategy { "strategy-#{generate(:identity_provider_number)}" }
    availability { "shared" }
    client_id { "client_id-#{generate(:identity_provider_number)}" }
    client_secret { "SuperSekret" }
  end
end
