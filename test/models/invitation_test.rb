require "test_helper"

describe Invitation do
  let(:practice) { practices(:acme_dental) }
  let(:inviter) { users(:alice) }

  describe "validations" do
    it "is invalid without an email" do
      inv = build(:invitation, practice: practice, invited_by: inviter, email: nil)
      refute inv.valid?
      assert inv.errors[:email].present?
    end

    it "is valid with a properly formatted email" do
      assert build(:invitation, practice: practice, invited_by: inviter, email: "user@example.com").valid?
    end

    it "is invalid with a malformed email" do
      inv = build(:invitation, practice: practice, invited_by: inviter, email: "not-an-email")
      refute inv.valid?
      assert inv.errors[:email].present?
    end

    describe "when the email domain is not allowed by the organization" do
      let(:org) { create(:organization) }
      let(:practice) { create(:practice, organization: org) }
      let(:inviter) { create(:another_user) }

      before do
        create(:organization, internal: true)
        create(:email_domain, domain_name: "allowed.com", organization: org)
      end

      it "is invalid for a disallowed domain" do
        invitation = build(:invitation, practice: practice, invited_by: inviter, email: "user@notallowed.com")
        refute invitation.valid?
        assert_includes invitation.errors[:email], "domain is not allowed for this organization"
      end

      it "is valid for an allowed domain" do
        invitation = build(:invitation, practice: practice, invited_by: inviter, email: "user@allowed.com")
        assert invitation.valid?
      end
    end

    describe "invitable roles" do
      it "excludes owner and admin from REGULAR_ROLES" do
        refute_includes PracticeMember::REGULAR_ROLES, "owner"
        refute_includes PracticeMember::REGULAR_ROLES, "admin"
      end

      it "includes member, dentist, hygienist, assistant in REGULAR_ROLES" do
        assert_includes PracticeMember::REGULAR_ROLES, "member"
        assert_includes PracticeMember::REGULAR_ROLES, "dentist"
        assert_includes PracticeMember::REGULAR_ROLES, "hygienist"
        assert_includes PracticeMember::REGULAR_ROLES, "assistant"
      end

      it "raises ArgumentError for owner role" do
        assert_raises(ArgumentError) do
          build(:invitation, practice: practice, invited_by: inviter, role: "owner")
        end
      end

      it "raises ArgumentError for admin role" do
        assert_raises(ArgumentError) do
          build(:invitation, practice: practice, invited_by: inviter, role: "admin")
        end
      end
    end
  end

  describe "normalizations" do
    it "strips and downcases the email" do
      invitation = create(:invitation, practice: practice, invited_by: inviter, email: "  USER@Example.COM  ")
      assert_equal "user@example.com", invitation.email
    end
  end

  describe "scopes" do
    # pending_to_carol and expired_to_eve come from fixtures; accepted_by_dave is accepted.

    describe ".pending" do
      it "includes unaccepted invitations created within 7 days" do
        assert_includes Invitation.pending, invitations(:pending_to_carol)
      end

      it "excludes accepted invitations" do
        refute_includes Invitation.pending, invitations(:accepted_by_dave)
      end

      it "excludes expired invitations" do
        refute_includes Invitation.pending, invitations(:expired_to_eve)
      end
    end

    describe ".accepted" do
      it "includes accepted invitations" do
        assert_includes Invitation.accepted, invitations(:accepted_by_dave)
      end

      it "excludes pending invitations" do
        refute_includes Invitation.accepted, invitations(:pending_to_carol)
      end
    end
  end

  describe "#pending?" do
    it "returns true for a fresh unaccepted invitation" do
      assert invitations(:pending_to_carol).pending?
    end

    it "returns false for an accepted invitation" do
      refute invitations(:accepted_by_dave).pending?
    end

    it "returns false for an expired invitation" do
      refute invitations(:expired_to_eve).pending?
    end
  end

  describe "#accepted?" do
    it "returns false when not accepted" do
      refute build(:invitation, practice: practice, invited_by: inviter).accepted?
    end

    it "returns true when accepted_at is set" do
      assert invitations(:accepted_by_dave).accepted?
    end
  end

  describe "#accept!" do
    let(:invitee) { create(:another_user) }
    let(:invitation) { create(:invitation, practice: practice, invited_by: inviter) }

    it "creates an organization membership" do
      assert_difference -> { OrganizationMember.where(organization: practice.organization, user: invitee).count }, 1 do
        invitation.accept!(invitee)
      end
    end

    it "creates a practice membership with the invitation role" do
      invitation.update!(role: :dentist)
      invitation.accept!(invitee)
      assert_equal "dentist", PracticeMember.find_by(practice: practice, user: invitee).role
    end

    it "marks the invitation as accepted" do
      invitation.accept!(invitee)
      assert invitation.reload.accepted?
    end

    it "is idempotent for organization membership" do
      create(:organization_member, organization: practice.organization, user: invitee)
      invitation.accept!(invitee)
      assert invitation.reload.accepted?
    end
  end

  describe ".accept_from_session!" do
    let(:invitation) do
      create(:invitation, practice: practice, invited_by: inviter, email: "invitee@example.com")
    end
    let(:invitee) { create(:another_user, email_address: "invitee@example.com") }
    let(:token) { invitation.generate_token_for(:acceptance) }
    let(:mock_session) { {invitation_token: token} }

    it "accepts the invitation and returns it" do
      result = Invitation.accept_from_session!(mock_session, invitee)
      assert_equal invitation, result
      assert invitation.reload.accepted?
    end

    it "deletes the token from the session" do
      Invitation.accept_from_session!(mock_session, invitee)
      refute mock_session.key?(:invitation_token)
    end

    it "returns nil when there is no token in the session" do
      assert_nil Invitation.accept_from_session!({}, invitee)
    end

    it "returns nil for an invalid token" do
      assert_nil Invitation.accept_from_session!({invitation_token: "bad-token"}, invitee)
    end

    it "returns nil for an already accepted invitation" do
      invitation.accept!(users(:dr_sue))
      assert_nil Invitation.accept_from_session!(mock_session, invitee)
    end
  end

  describe "token generation" do
    let(:invitation) { create(:invitation, practice: practice, invited_by: inviter) }

    it "generates a valid acceptance token" do
      token = invitation.generate_token_for(:acceptance)
      assert_equal invitation, Invitation.find_by_token_for(:acceptance, token)
    end

    it "invalidates the token after acceptance" do
      token = invitation.generate_token_for(:acceptance)
      invitation.accept!(create(:another_user))
      assert_nil Invitation.find_by_token_for(:acceptance, token)
    end
  end
end
