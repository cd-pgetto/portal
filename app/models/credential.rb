# == Schema Information
#
# Table name: credentials
# Database name: primary
#
#  id                   :uuid             not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identity_provider_id :uuid             not null
#  organization_id      :uuid             not null
#
# Indexes
#
#  index_credentials_on_identity_provider_id                      (identity_provider_id)
#  index_credentials_on_organization_id                           (organization_id)
#  index_credentials_on_organization_id_and_identity_provider_id  (organization_id,identity_provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (identity_provider_id => identity_providers.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class Credential < ApplicationRecord
  belongs_to :organization
  belongs_to :identity_provider

  scope :shared, -> { joins(:identity_provider).merge(IdentityProvider.shared) }
  scope :dedicated, -> { joins(:identity_provider).merge(IdentityProvider.dedicated) }

  validates :organization_id, uniqueness: {scope: :identity_provider_id}

  accepts_nested_attributes_for :identity_provider, allow_destroy: true, reject_if: :all_blank_except_availability

  def all_blank_except_availability(attributes)
    attributes.except("availability").values.all?(&:blank?)
  end
end
