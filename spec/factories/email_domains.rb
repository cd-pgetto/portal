# == Schema Information
#
# Table name: email_domains
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
FactoryBot.define do
  factory :email_domain do
    domain_name { "example.com" }
    organization

    factory :perceptive_io_email_domain do
      domain_name { "perceptive.io" }
    end

    factory :cyberdontics_io_email_domain do
      domain_name { "cyberdontics.io" }
    end

    factory :cyberdontics_co_email_domain do
      domain_name { "cyberdontics.co" }
    end
  end
end
