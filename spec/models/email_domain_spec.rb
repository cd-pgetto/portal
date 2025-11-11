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
require "rails_helper"

RSpec.describe EmailDomain, type: :model do
  describe "validations" do
    subject { build(:email_domain) }

    it { is_expected.to validate_presence_of(:domain_name) }
    it { is_expected.to validate_uniqueness_of(:domain_name).ignoring_case_sensitivity }

    context "with valid domain names" do
      DomainNames::VALID_FULL_DOMAIN_NAMES.each do |address|
        it { should allow_value(address).for(:domain_name) }
      end
    end

    context "with invalid domain names" do
      DomainNames::INVALID_FULL_DOMAIN_NAMES.each do |address|
        it { should_not allow_value(address).for(:domain_name) }
      end
    end
  end
end
