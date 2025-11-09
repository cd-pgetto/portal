# == Schema Information
#
# Table name: organizations
#
#  id                   :uuid             not null, primary key
#  allows_password_auth :boolean          default(TRUE), not null
#  name                 :string           not null
#  subdomain            :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_organizations_on_subdomain  (subdomain) UNIQUE
#
class Organization < ApplicationRecord
  has_many :credentials, dependent: :destroy
  has_many :identity_providers, through: :credentials

  has_many :shared_identity_providers, -> { shared }, through: :credentials, source: :identity_provider
  has_many :dedicated_identity_providers, -> { dedicated }, through: :credentials, source: :identity_provider

  normalizes :subdomain, with: ->(value) { value.strip.downcase }

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: {case_sensitive: false},
    length: {minimum: 1, maximum: 63}, format: {with: DomainName::SUBDOMAIN_REGEXP}

  accepts_nested_attributes_for :credentials, allow_destroy: true, reject_if: :all_blank

  # Custom getter for shared identity provider IDs
  def shared_identity_provider_ids
    shared_identity_providers.pluck(:id)
  end

  # Custom setter for shared identity provider IDs
  # This manages only shared provider credentials without affecting dedicated ones
  def shared_identity_provider_ids=(ids)
    # Filter out blank values
    ids = ids.compact_blank

    # Get current shared provider IDs
    current_shared_ids = shared_identity_provider_ids

    # Find which shared credentials to remove
    to_remove = current_shared_ids - ids
    credentials.joins(:identity_provider)
      .where(identity_providers: {id: to_remove, availability: :shared})
      .destroy_all

    # Find which shared credentials to add
    to_add = ids - current_shared_ids
    to_add.each do |provider_id|
      credentials.find_or_create_by(identity_provider_id: provider_id)
    end
  end
end
