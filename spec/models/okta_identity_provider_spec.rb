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
require "rails_helper"

RSpec.describe OktaIdentityProvider, type: :model do
  subject { build(:okta_identity_provider) }

  it { is_expected.to be_a(IdentityProvider) }
  it { is_expected.to validate_presence_of(:okta_domain) }
end
