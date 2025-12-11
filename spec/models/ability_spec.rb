require "rails_helper"

MANAGED_MODELS = [Credential, EmailDomain, IdentityProvider, Organization, User, Practice].freeze
ACTIONS = [:create, :read, :update, :destroy, :manage].freeze

RSpec.describe Ability, type: :ability do
  subject(:ability) { Ability.new(user) }
  let(:user) { nil }

  describe "without any user" do
    context "User models" do
      it { is_expected.to be_able_to(:create, User.new) }
      [:read, :update, :destroy, :manage].each { |action| it { is_expected.not_to be_able_to(action, User.new) } }

      let(:another_user) { create(:another_user) }
      [:read, :update, :destroy, :manage].each { |action| it { is_expected.not_to be_able_to(action, another_user) } }
    end

    (MANAGED_MODELS - [User]).each do |model|
      ACTIONS.each do |action|
        it { is_expected.not_to be_able_to(action, model.new) }
      end
    end
  end

  context "as a regular user" do
    let(:user) { create(:user, organization: create(:organization)) }

    context "User models" do
      [:read, :update].each { |action| it { is_expected.to be_able_to(action, user) } }
      [:create, :destroy, :manage].each { |action| it { is_expected.not_to be_able_to(action, user) } }
    end

    context "EmailDomain models" do
      let(:email_domain) { EmailDomain.new(organization_id: user.organization_membership.organization_id) }
      it { is_expected.to be_able_to(:read, email_domain) }

      let(:other_email_domain) { EmailDomain.new(organization_id: create(:organization).id) }
      it { is_expected.not_to be_able_to(:read, other_email_domain) }

      [:create, :update, :destroy, :manage].each { |action|
        it { is_expected.not_to be_able_to(action, email_domain) }
      }
    end

    context "Practice models" do
      let(:practice) { create(:practice, users: [user], organization_id: user.organization_membership.organization_id) }
      it { is_expected.to be_able_to(:read, practice) }

      let(:other_practice) { Practice.new(organization_id: create(:organization).id) }
      it { is_expected.not_to be_able_to(:read, other_practice) }

      [:create, :update, :destroy, :manage].each { |action|
        it { is_expected.not_to be_able_to(action, practice) }
      }
    end

    (MANAGED_MODELS - [User, EmailDomain, Practice]).each do |model|
      ACTIONS.each do |action|
        it { is_expected.not_to be_able_to(action, model.new) }
      end
    end
  end

  context "as an organization admin" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before { user.create_organization_membership(organization: organization, role: :admin) }

    context "EmailDomain models" do
      [:create, :update].each do |action|
        it { is_expected.to be_able_to(action, EmailDomain.new(organization_id: organization.id)) }
        it { is_expected.not_to be_able_to(action, EmailDomain.new(organization_id: create(:organization).id)) }
      end

      [:destroy, :manage].each do |action|
        it { is_expected.not_to be_able_to(action, EmailDomain.new(organization_id: organization.id)) }
      end
    end

    context "IdentityProvider models" do
      [:create, :update].each do |action|
        it {
          identity_provider = IdentityProvider.new
          allow(identity_provider).to receive(:dedicated?).and_return(true)
          allow(identity_provider).to receive(:organization_ids).and_return([organization.id])
          is_expected.to be_able_to(action, identity_provider)
        }

        it {
          identity_provider = IdentityProvider.new
          allow(identity_provider).to receive(:dedicated?).and_return(false)
          is_expected.not_to be_able_to(action, identity_provider)
        }

        it {
          identity_provider = IdentityProvider.new
          allow(identity_provider).to receive(:dedicated?).and_return(true)
          allow(identity_provider).to receive(:organization_ids).and_return([create(:organization).id])
          is_expected.not_to be_able_to(action, identity_provider)
        }
      end

      [:destroy, :manage].each do |action|
        it { is_expected.not_to be_able_to(action, IdentityProvider.new) }
      end
    end

    context "Organization models" do
      it { is_expected.to be_able_to(:update, Organization.new(id: organization.id)) }
      [:create, :destroy, :manage].each do |action|
        it { is_expected.not_to be_able_to(action, Organization.new(id: organization.id)) }
      end
    end

    context "Credential models" do
      [:create, :update].each do |action|
        it { is_expected.to be_able_to(action, Credential.new(organization_id: organization.id)) }
        it { is_expected.not_to be_able_to(action, Credential.new(organization_id: create(:organization).id)) }
      end

      [:destroy, :manage].each do |action|
        it { is_expected.not_to be_able_to(action, Credential.new(organization_id: organization.id)) }
      end
    end
  end

  describe "as a system admin" do
    let(:user) { create_system_admin }

    MANAGED_MODELS.each do |model|
      ACTIONS.each do |action|
        it { is_expected.to be_able_to(action, model.new) }
      end
    end
  end
end
