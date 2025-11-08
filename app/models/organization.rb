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
end
