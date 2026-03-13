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
class IdentityProvider < ApplicationRecord
  has_many :organization_shared_identity_providers, dependent: :destroy
  has_many :organizations, through: :organization_shared_identity_providers
  has_many :identities, dependent: :destroy

  validates :name, :icon_url, :strategy, presence: true

  # Shared providers must have a unique strategy globally
  validates :strategy, uniqueness: {conditions: -> { where(organization_id: nil) }}, if: -> { !dedicated? }

  scope :shared, -> { where(organization_id: nil) }
  scope :dedicated, -> { where.not(organization_id: nil) }

  def shared? = !dedicated?
  def dedicated? = false

  def self.policy_class = IdentityProviderPolicy

  def self.inherited(subclass)
    super
    subclass.define_singleton_method(:model_name) { IdentityProvider.model_name }
  end

  # List of available OAuth strategies
  def self.available_strategies
    OmniAuth.strategies.map(&:default_options).map(&:name).compact.map(&:to_s).sort
  end
end
