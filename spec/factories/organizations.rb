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
FactoryBot.define do
  sequence(:organization_number) { |n| n }

  factory :organization do
    name { "Organization #{generate(:organization_number)}" }
    subdomain { "org-#{generate(:organization_number)}" }
    allows_password_auth { true }
  end
end
