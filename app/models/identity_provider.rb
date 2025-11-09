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
class IdentityProvider < ApplicationRecord
  has_many :credentials, dependent: :destroy
  has_many :organizations, through: :credentials

  enum :availability, {shared: "shared", dedicated: "dedicated"}

  validates :name, presence: true
  validates :icon_url, presence: true
  validates :strategy, presence: true, uniqueness: {conditions: -> { shared }}
  validates :client_id, presence: true, uniqueness: {scope: :strategy}
  validates :client_secret, presence: true

  # List of available OAuth strategies
  def self.available_strategies
    OmniAuth.strategies.map(&:default_options).map(&:name).compact
  end
end
