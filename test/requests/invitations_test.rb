require "test_helper"

class InvitationsTest < ActionDispatch::IntegrationTest
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:inviter) { create_member_in(practice) }
  let(:invitation) { create(:invitation, practice: practice, invited_by: inviter, email: "newuser@example.com") }
  let(:token) { invitation.generate_token_for(:acceptance) }

  before {
    organization
    practice
    inviter
    invitation
  }

  describe "GET /invitations/:token" do
    describe "with a valid pending invitation" do
      it "renders the invitation landing page" do
        get invitation_path(token)
        assert_response :success
      end

      it "stores the token in session" do
        get invitation_path(token)
        assert_equal token, session[:invitation_token]
      end
    end

    describe "with an invalid token" do
      it "redirects to root with an alert" do
        get invitation_path("invalid-token")
        assert_redirected_to root_path
        assert_includes flash[:alert], "invalid or has expired"
      end
    end

    describe "with an expired invitation" do
      let(:invitation) { create(:invitation, :expired, practice: practice, invited_by: inviter, email: "newuser@example.com") }

      it "redirects to root with an alert" do
        get invitation_path(token)
        assert_redirected_to root_path
        assert_includes flash[:alert], "invalid or has expired"
      end
    end

    describe "with an already accepted invitation" do
      let(:invitation) { create(:invitation, :accepted, practice: practice, invited_by: inviter, email: "newuser@example.com") }

      it "redirects to root with an alert" do
        get invitation_path(token)
        assert_redirected_to root_path
        assert_includes flash[:alert], "invalid or has expired"
      end
    end
  end

  describe "PATCH /invitations/:token/accept" do
    describe "when not signed in" do
      it "redirects to sign in" do
        patch accept_invitation_path(token)
        assert_redirected_to new_session_path
      end
    end

    describe "when signed in as the invited user" do
      let(:invited_user) { create(:another_user, email_address: "newuser@example.com") }
      before { sign_in_as(invited_user, USER_PASSWORD) }

      it "accepts the invitation and redirects to the practice" do
        patch accept_invitation_path(token)
        assert_redirected_to practice_path(practice)
        assert_includes flash[:notice], "You have joined"
      end

      it "creates a practice membership for the user" do
        assert_difference -> { PracticeMember.where(practice: practice, user: invited_user).count }, 1 do
          patch accept_invitation_path(token)
        end
      end

      it "creates an organization membership for the user" do
        assert_difference -> { OrganizationMember.where(organization: organization, user: invited_user).count }, 1 do
          patch accept_invitation_path(token)
        end
      end

      it "marks the invitation as accepted" do
        patch accept_invitation_path(token)
        assert invitation.reload.accepted?
      end
    end

    describe "when signed in as a different user" do
      let(:other_user) { create(:another_user) }
      before { sign_in_as(other_user, USER_PASSWORD) }

      it "redirects back to the invitation with an alert" do
        patch accept_invitation_path(token)
        assert_redirected_to invitation_path(token)
        assert_includes flash[:alert], "newuser@example.com"
      end

      it "does not accept the invitation" do
        patch accept_invitation_path(token)
        assert_not invitation.reload.accepted?
      end
    end

    describe "with an expired invitation" do
      let(:invitation) { create(:invitation, :expired, practice: practice, invited_by: inviter, email: "newuser@example.com") }
      let(:invited_user) { create(:another_user, email_address: "newuser@example.com") }
      before { sign_in_as(invited_user, USER_PASSWORD) }

      it "redirects to root with an alert" do
        patch accept_invitation_path(token)
        assert_redirected_to root_path
        assert_includes flash[:alert], "invalid or has expired"
      end
    end
  end

  describe "invitation acceptance via sign in" do
    let(:existing_user) { create(:another_user, email_address: "newuser@example.com") }

    it "does not accept the invitation when signing in as a different user" do
      attacker = create(:another_user)
      create(:organization_member, organization: organization, user: attacker)
      get invitation_path(token)
      post session_path, params: {sign_in_step: 2, email_address: attacker.email_address, password: USER_PASSWORD}
      assert_not invitation.reload.accepted?
      assert_not PracticeMember.where(practice: practice, user: attacker).exists?
    end

    it "accepts the invitation after signing in with the invited email" do
      existing_user
      get invitation_path(token)
      post session_path, params: {sign_in_step: 2, email_address: existing_user.email_address, password: USER_PASSWORD}
      assert_redirected_to practice_path(practice)
      assert invitation.reload.accepted?
      assert PracticeMember.where(practice: practice, user: existing_user).exists?
    end
  end

  describe "invitation acceptance via sign up" do
    it "accepts the invitation after creating a new account" do
      get invitation_path(token)
      post users_path, params: {
        user: {
          email_address: "newuser@example.com",
          first_name: "Jane",
          last_name: "Doe",
          password: "SuperSecurePassword123!",
          registration_step: 2
        }
      }
      new_user = User.find_by(email_address: "newuser@example.com")
      assert_redirected_to practice_path(practice)
      assert invitation.reload.accepted?
      assert PracticeMember.where(practice: practice, user: new_user).exists?
    end
  end
end
