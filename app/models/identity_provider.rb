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
class IdentityProvider < ApplicationRecord
  has_many :credentials, dependent: :destroy
  has_many :organizations, through: :credentials
  has_many :identities, dependent: :destroy

  enum :availability, {shared: "shared", dedicated: "dedicated"}

  validates :name, :icon_url, :strategy, :client_id, :client_secret, presence: true

  # Can only have single shared identity provider per strategy
  validates :strategy, uniqueness: {conditions: -> { shared }}, if: -> { shared? }

  # Can only have single identity provider per strategy and client_id combination
  validates :client_id, uniqueness: {scope: :strategy}

  # List of available OAuth strategies
  def self.available_strategies
    OmniAuth.strategies.map(&:default_options).map(&:name).compact.map(&:to_s).sort
  end
end
