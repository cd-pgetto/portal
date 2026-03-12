class IdentityProvider < ApplicationRecord
  has_many :organization_shared_identity_providers, dependent: :destroy
  has_many :organizations, through: :organization_shared_identity_providers
  has_many :identities, dependent: :destroy

  validates :name, :icon_url, :strategy, :client_id, :client_secret, presence: true

  # Shared providers must have a unique strategy globally
  validates :strategy, uniqueness: {conditions: -> { where(organization_id: nil) }}, if: -> { !dedicated? }

  # No two providers with the same strategy and client_id
  validates :client_id, uniqueness: {scope: :strategy}

  scope :shared, -> { where(organization_id: nil) }
  scope :dedicated, -> { where.not(organization_id: nil) }

  def shared? = !dedicated?
  def dedicated? = false

  # List of available OAuth strategies
  def self.available_strategies
    OmniAuth.strategies.map(&:default_options).map(&:name).compact.map(&:to_s).sort
  end
end
