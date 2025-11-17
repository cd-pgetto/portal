# == Schema Information
#
# Table name: email_domains
# Database name: primary
#
#  id              :uuid             not null, primary key
#  domain_name     :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid             not null
#
# Indexes
#
#  index_email_domains_on_domain_name      (domain_name) UNIQUE
#  index_email_domains_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class EmailDomain < ApplicationRecord
  belongs_to :organization

  validates :domain_name, presence: true, uniqueness: {case_sensitive: false},
    format: {with: DomainName::FULL_DOMAIN_REGEXP}

  normalizes :domain_name, with: ->(value) { value.strip.downcase }
end
