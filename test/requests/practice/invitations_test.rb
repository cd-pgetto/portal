require "test_helper"

class Practice::InvitationsTest < ActionDispatch::IntegrationTest
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:admin) { create_member_in(practice, role: :admin) }

  before {
    practice
    sign_in_as(admin, USER_PASSWORD)
  }

  describe "POST /practices/:practice_id/invitations" do
    let(:valid_params) { {invitation: {email: "newuser@example.com", role: "member"}} }

    it "creates a pending invitation" do
      assert_difference -> { practice.invitations.count }, 1 do
        post practice_invitations_path(practice), params: valid_params
      end
    end

    it "sends an invitation email" do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
        post practice_invitations_path(practice), params: valid_params
      end
    end

    it "redirects to the practice edit page with a notice" do
      post practice_invitations_path(practice), params: valid_params
      assert_redirected_to edit_practice_path(practice)
      assert_includes flash[:notice], "Invitation sent"
    end

    describe "when a pending invitation already exists for that email" do
      before { create(:invitation, practice: practice, invited_by: admin, email: "newuser@example.com") }

      it "replaces the existing invitation" do
        assert_no_difference -> { practice.invitations.pending.count } do
          post practice_invitations_path(practice), params: valid_params
        end
      end
    end

    describe "with an invalid email" do
      it "redirects with an error" do
        post practice_invitations_path(practice), params: {invitation: {email: "not-an-email", role: "member"}}
        assert_redirected_to edit_practice_path(practice)
        assert flash[:alert].present?
      end
    end

    describe "when signed in as a non-admin member" do
      let(:member) { create_member_in(practice) }

      before do
        delete session_path
        sign_in_as(member, USER_PASSWORD)
      end

      it "is not authorized" do
        post practice_invitations_path(practice), params: valid_params
        assert_redirected_to home_path
        assert_includes flash[:alert], "not authorized"
      end
    end
  end

  describe "DELETE /practices/:practice_id/invitations/:id" do
    let(:invitation) { create(:invitation, practice: practice, invited_by: admin, email: "newuser@example.com") }
    before { invitation }

    it "destroys the invitation" do
      assert_difference -> { practice.invitations.count }, -1 do
        delete practice_invitation_path(practice, invitation)
      end
    end

    it "redirects to the practice edit page with a notice" do
      delete practice_invitation_path(practice, invitation)
      assert_redirected_to edit_practice_path(practice)
      assert_includes flash[:notice], "cancelled"
    end

    describe "when signed in as a non-admin member" do
      let(:member) { create_member_in(practice) }

      before do
        delete session_path
        sign_in_as(member, USER_PASSWORD)
      end

      it "is not authorized" do
        delete practice_invitation_path(practice, invitation)
        assert_redirected_to home_path
        assert_includes flash[:alert], "not authorized"
      end
    end
  end
end
