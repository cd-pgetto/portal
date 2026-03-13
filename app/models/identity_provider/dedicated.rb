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
class IdentityProvider::Dedicated < IdentityProvider
  STRATEGY_CLASS_MAP = {
    "okta" => "IdentityProvider::Okta"
  }.freeze

  encrypts :client_id, :client_secret

  belongs_to :organization

  validates :organization, :client_id, :client_secret, presence: true

  def self.class_for_strategy(strategy)
    STRATEGY_CLASS_MAP[strategy]
  end

  def self.dedicated_strategies
    STRATEGY_CLASS_MAP.keys
  end
end
