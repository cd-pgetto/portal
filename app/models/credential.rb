# == Schema Information
#
# Table name: credentials
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  identity_provider_id :bigint           not null
#  organization_id      :bigint           not null
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

  validates :organization_id, uniqueness: {scope: :identity_provider_id}
end
