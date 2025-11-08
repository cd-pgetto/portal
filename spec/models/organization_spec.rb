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
require "rails_helper"

RSpec.describe Organization, type: :model do
  subject { build(:organization) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:subdomain) }
    it { is_expected.to validate_uniqueness_of(:subdomain).ignoring_case_sensitivity }
    it { is_expected.to validate_length_of(:subdomain).is_at_least(1).is_at_most(63) }

    context "with valid subdomain names" do
      DomainNames::VALID_SUBDOMAIN_NAMES.each do |domain_name|
        it { is_expected.to allow_value(domain_name).for(:subdomain) }
      end
    end

    context "with invalid subdomain names" do
      DomainNames::INVALID_SUBDOMAIN_NAMES.each do |domain_name|
        it { is_expected.not_to allow_value(domain_name).for(:subdomain) }
      end
    end
  end
end
