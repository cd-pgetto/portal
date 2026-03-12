class DedicatedIdentityProvider < IdentityProvider
  require_relative "okta_identity_provider"

  STRATEGY_CLASS_MAP = {
    "okta" => "OktaIdentityProvider"
  }.freeze

  belongs_to :organization

  validates :organization, presence: true

  def self.class_for_strategy(strategy)
    STRATEGY_CLASS_MAP[strategy]
  end

  def self.dedicated_strategies
    STRATEGY_CLASS_MAP.keys
  end

  def dedicated? = true
end
