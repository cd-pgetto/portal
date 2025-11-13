# == Schema Information
#
# Table name: organizations
#
#  id                    :uuid             not null, primary key
#  name                  :string           not null
#  password_auth_allowed :boolean          default(TRUE), not null
#  subdomain             :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
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
  has_many :email_domains, dependent: :destroy

  normalizes :subdomain, with: ->(value) { value.strip.downcase }

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: {case_sensitive: false},
    length: {minimum: 1, maximum: 63}, format: {with: DomainName::SUBDOMAIN_REGEXP}
  validates :identity_providers, presence: {message: "must have at least one identity provider if password authentication is not allowed", unless: :password_auth_allowed}

  accepts_nested_attributes_for :credentials, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :email_domains, allow_destroy: true, reject_if: :all_blank

  def self.find_by_email(email)
    return nil unless (domain_name = email_domain(email))
    joins(:email_domains).find_by(email_domains: {domain_name: domain_name}) || Organization::Null.new
  end

  def self.find_by_subdomain_or_email(subdomain, email)
    find_by(subdomain: subdomain) || find_by_email(email) || Organization::Null.new
  end

  def self.identity_providers_by_email(email)
    find_by_email(email)&.identity_providers
  end

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

  private_class_method def self.email_domain(email)
    email&.split("@")&.last&.downcase
  end

  private

  def email_domain(email) = self.class.send(:email_domain, email)

  public

  class Null < Organization
    after_initialize :set_defaults

    private

    def set_defaults
      self.name = "Undefined Organization"
      self.subdomain = "undefined-organization"
      self.password_auth_allowed = true
    end
  end
end
