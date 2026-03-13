# == Schema Information
#
# Table name: organizations
# Database name: primary
#
#  id                    :uuid             not null, primary key
#  email_domains_count   :integer          default(0), not null
#  internal              :boolean          default(FALSE), not null
#  name                  :string           not null
#  password_auth_allowed :boolean          default(TRUE), not null
#  practices_count       :integer          default(0), not null
#  subdomain             :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_organizations_on_internal   (internal) UNIQUE WHERE (internal = true)
#  index_organizations_on_subdomain  (subdomain) UNIQUE
#
class Organization < ApplicationRecord
  has_many :organization_shared_identity_providers, dependent: :destroy
  has_many :shared_identity_providers, through: :organization_shared_identity_providers, source: :identity_provider
  has_one :dedicated_identity_provider, dependent: :destroy

  has_many :email_domains, dependent: :destroy
  has_many :practices, dependent: :destroy

  has_many :members, class_name: "OrganizationMember", dependent: :destroy
  has_many :users, through: :members

  normalizes :subdomain, with: ->(value) { value.strip.downcase }

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: {case_sensitive: false},
    length: {minimum: 1, maximum: 63}, format: {with: DomainName::SUBDOMAIN_REGEXP}
  validate :has_identity_provider_if_password_auth_not_allowed
  validate :authentication_mode_is_exclusive

  accepts_nested_attributes_for :organization_shared_identity_providers, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :dedicated_identity_provider, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :email_domains, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :practices, allow_destroy: true, reject_if: :all_blank

  # Returns all identity providers for this organization — shared (via join table)
  # and dedicated (via direct organization_id FK). Mutually exclusive in practice.
  # Use shared_identity_providers.ids to handle the case of a new, unsaved organization which
  # can have in-memory shared identity providers.
  def identity_providers
    IdentityProvider.where(id: shared_identity_providers.ids)
      .or(IdentityProvider.where(organization_id: id).where.not(type: "IdentityProvider"))
  end

  def self.find_by_email(email)
    domain_name = email_domain(email)
    return nil if domain_name.nil?
    joins(:email_domains).find_by(email_domains: {domain_name: domain_name}) || Organization::Null.new
  end

  def self.find_by_subdomain_or_email(subdomain, email)
    find_by(subdomain: subdomain) || find_by_email(email) || Organization::Null.new
  end

  def self.identity_providers_by_email(email)
    find_by_email(email)&.identity_providers
  end

  def primary_email_domain
    email_domains.order(:created_at).first&.domain_name
  end

  def email_allowed?(email)
    return true if email_domains.empty?

    domain = email_domain(email)
    return false if domain.nil?
    email_domains.exists?(domain_name: domain) ||
      Organization.find_by!(internal: true).email_domains.exists?(domain_name: domain)
  end

  def shared_identity_provider_ids
    shared_identity_providers.pluck(:id)
  end

  def shared_identity_provider_ids=(ids)
    ids = ids.compact_blank

    current_shared_ids = shared_identity_provider_ids

    to_remove = current_shared_ids - ids
    organization_shared_identity_providers
      .where(identity_provider_id: to_remove)
      .destroy_all

    to_add = ids - current_shared_ids
    to_add.each do |provider_id|
      organization_shared_identity_providers.find_or_create_by(identity_provider_id: provider_id)
    end
  end

  private_class_method def self.email_domain(email)
    email&.split("@")&.last&.downcase
  end

  private

  def email_domain(email) = self.class.send(:email_domain, email)

  def has_identity_provider_if_password_auth_not_allowed
    return if password_auth_allowed?
    unless shared_identity_providers.any? || dedicated_identity_provider.present?
      errors.add(:base, "must have at least one identity provider if password authentication is not allowed")
    end
  end

  def authentication_mode_is_exclusive
    return unless dedicated_identity_provider.present?
    if shared_identity_providers.any?
      errors.add(:base, "cannot have both a dedicated identity provider and shared identity providers")
    end
    if password_auth_allowed?
      errors.add(:base, "password authentication must be disabled when using a dedicated identity provider")
    end
  end

  public

  class Null < Organization
    after_initialize :set_defaults

    # If no organization is found, all shared identity providers are available
    def identity_providers
      IdentityProvider.shared
    end

    private

    def set_defaults
      self.name = "Undefined Organization"
      self.subdomain = "undefined-organization"
      self.password_auth_allowed = true
    end
  end
end
