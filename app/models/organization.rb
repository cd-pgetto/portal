# == Schema Information
#
# Table name: organizations
#
#  id                   :bigint           not null, primary key
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
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: {case_sensitive: false},
    length: {minimum: 1, maximum: 63}, format: {with: DomainName::SUBDOMAIN_REGEXP}
end
