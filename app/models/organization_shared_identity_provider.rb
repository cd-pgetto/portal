class OrganizationSharedIdentityProvider < ApplicationRecord
  belongs_to :organization
  belongs_to :identity_provider

  validates :organization_id, uniqueness: {scope: :identity_provider_id}
end
