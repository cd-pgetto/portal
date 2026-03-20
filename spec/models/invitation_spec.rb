# == Schema Information
#
# Table name: invitations
# Database name: primary
#
#  id            :uuid             not null, primary key
#  accepted_at   :datetime
#  email         :string           not null
#  role          :enum             default("member"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :uuid             not null
#  practice_id   :uuid             not null
#
# Indexes
#
#  index_invitations_on_invited_by_id                  (invited_by_id)
#  index_invitations_on_practice_id                    (practice_id)
#  index_invitations_on_practice_id_and_email_pending  (practice_id,email) UNIQUE WHERE (accepted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (practice_id => practices.id)
#
require "rails_helper"

RSpec.describe Invitation, type: :model do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:inviter) { create(:user, organization: organization, practices: [practice]) }

  subject { build(:invitation, practice: practice, invited_by: inviter) }

  describe "associations" do
    it { is_expected.to belong_to(:practice) }
    it { is_expected.to belong_to(:invited_by).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:role) }

    it { is_expected.to allow_value("user@example.com").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }

    context "when the email domain is not allowed by the organization" do
      before do
        create(:organization, internal: true)
        create(:email_domain, domain_name: "allowed.com", organization: organization)
      end

      it "is invalid" do
        invitation = build(:invitation, practice: practice, invited_by: inviter, email: "user@notallowed.com")
        expect(invitation).not_to be_valid
        expect(invitation.errors[:email]).to include("domain is not allowed for this organization")
      end

      it "is valid for an allowed domain" do
        invitation = build(:invitation, practice: practice, invited_by: inviter, email: "user@allowed.com")
        expect(invitation).to be_valid
      end
    end

    context "invitable roles" do
      it "excludes owner and admin" do
        expect(PracticeMember::REGULAR_ROLES).not_to include("owner", "admin")
      end

      it "includes member, dentist, hygienist, assistant" do
        expect(PracticeMember::REGULAR_ROLES).to include("member", "dentist", "hygienist", "assistant")
      end

      it "raises ArgumentError for owner role" do
        expect { build(:invitation, practice: practice, invited_by: inviter, role: "owner") }
          .to raise_error(ArgumentError)
      end

      it "raises ArgumentError for admin role" do
        expect { build(:invitation, practice: practice, invited_by: inviter, role: "admin") }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe "normalizations" do
    it "strips and downcases the email" do
      invitation = create(:invitation, practice: practice, invited_by: inviter, email: "  USER@Example.COM  ")
      expect(invitation.email).to eq("user@example.com")
    end
  end

  describe "scopes" do
    let!(:pending_invitation) { create(:invitation, practice: practice, invited_by: inviter) }
    let!(:accepted_invitation) { create(:invitation, :accepted, practice: practice, invited_by: inviter, email: "accepted@example.com") }
    let!(:expired_invitation) { create(:invitation, :expired, practice: practice, invited_by: inviter, email: "expired@example.com") }

    describe ".pending" do
      it "includes unaccepted invitations created within 7 days" do
        expect(Invitation.pending).to include(pending_invitation)
      end

      it "excludes accepted invitations" do
        expect(Invitation.pending).not_to include(accepted_invitation)
      end

      it "excludes expired invitations" do
        expect(Invitation.pending).not_to include(expired_invitation)
      end
    end

    describe ".accepted" do
      it "includes accepted invitations" do
        expect(Invitation.accepted).to include(accepted_invitation)
      end

      it "excludes pending invitations" do
        expect(Invitation.accepted).not_to include(pending_invitation)
      end
    end
  end

  describe "#pending?" do
    it "returns true for a fresh unaccepted invitation" do
      expect(create(:invitation, practice: practice, invited_by: inviter)).to be_pending
    end

    it "returns false for an accepted invitation" do
      expect(build(:invitation, :accepted)).not_to be_pending
    end

    it "returns false for an expired invitation" do
      expect(build(:invitation, :expired)).not_to be_pending
    end
  end

  describe "#accepted?" do
    it "returns false when not accepted" do
      expect(subject).not_to be_accepted
    end

    it "returns true when accepted_at is set" do
      expect(build(:invitation, :accepted)).to be_accepted
    end
  end

  describe "#accept!" do
    let(:invitee) { create(:another_user) }
    let(:invitation) { create(:invitation, practice: practice, invited_by: inviter) }

    it "creates an organization membership" do
      expect { invitation.accept!(invitee) }
        .to change { OrganizationMember.where(organization: organization, user: invitee).count }.by(1)
    end

    it "creates a practice membership with the invitation role" do
      invitation.update!(role: :dentist)
      invitation.accept!(invitee)
      expect(PracticeMember.find_by(practice: practice, user: invitee).role).to eq("dentist")
    end

    it "marks the invitation as accepted" do
      invitation.accept!(invitee)
      expect(invitation.reload).to be_accepted
    end

    it "is idempotent for organization membership" do
      create(:organization_member, organization: organization, user: invitee)
      expect { invitation.accept!(invitee) }.not_to raise_error
    end
  end

  describe ".accept_from_session!" do
    let(:invitation) { create(:invitation, practice: practice, invited_by: inviter, email: "invitee@example.com") }
    let(:invitee) { create(:another_user, email_address: "invitee@example.com") }
    let(:token) { invitation.generate_token_for(:acceptance) }
    let(:mock_session) { {invitation_token: token} }

    it "accepts the invitation and returns it" do
      result = Invitation.accept_from_session!(mock_session, invitee)
      expect(result).to eq(invitation)
      expect(invitation.reload).to be_accepted
    end

    it "deletes the token from the session" do
      Invitation.accept_from_session!(mock_session, invitee)
      expect(mock_session).not_to have_key(:invitation_token)
    end

    it "returns nil when there is no token in the session" do
      expect(Invitation.accept_from_session!({}, invitee)).to be_nil
    end

    it "returns nil for an invalid token" do
      expect(Invitation.accept_from_session!({invitation_token: "bad-token"}, invitee)).to be_nil
    end

    it "returns nil for an already accepted invitation" do
      invitation.accept!(create(:dr_sue))
      expect(Invitation.accept_from_session!(mock_session, invitee)).to be_nil
    end
  end

  describe "token generation" do
    let(:invitation) { create(:invitation, practice: practice, invited_by: inviter) }

    it "generates a valid acceptance token" do
      token = invitation.generate_token_for(:acceptance)
      expect(Invitation.find_by_token_for(:acceptance, token)).to eq(invitation)
    end

    it "invalidates the token after acceptance" do
      token = invitation.generate_token_for(:acceptance)
      invitation.accept!(create(:another_user))
      expect(Invitation.find_by_token_for(:acceptance, token)).to be_nil
    end
  end
end
