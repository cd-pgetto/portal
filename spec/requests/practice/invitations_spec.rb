require "rails_helper"

RSpec.describe "Practice::Invitations", type: :request do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:admin) { create(:user, organization: organization, practices: [practice]) }

  before do
    admin.practice_memberships.find_by(practice: practice).update!(role: :admin)
    sign_in_as(admin, attributes_for(:user)[:password])
  end

  describe "POST /practices/:practice_id/invitations" do
    let(:valid_params) { {invitation: {email: "newuser@example.com", role: "member"}} }

    it "creates a pending invitation" do
      expect { post practice_invitations_path(practice), params: valid_params }
        .to change { practice.invitations.count }.by(1)
    end

    it "sends an invitation email" do
      expect { post practice_invitations_path(practice), params: valid_params }
        .to have_enqueued_mail(InvitationsMailer, :invite)
    end

    it "redirects to the practice edit page with a notice" do
      post practice_invitations_path(practice), params: valid_params
      expect(response).to redirect_to(edit_practice_path(practice))
      expect(flash[:notice]).to include("Invitation sent")
    end

    context "when a pending invitation already exists for that email" do
      before { create(:invitation, practice: practice, invited_by: admin, email: "newuser@example.com") }

      it "replaces the existing invitation" do
        expect { post practice_invitations_path(practice), params: valid_params }
          .not_to change { practice.invitations.pending.count }
      end
    end

    context "with an invalid email" do
      it "redirects with an error" do
        post practice_invitations_path(practice), params: {invitation: {email: "not-an-email", role: "member"}}
        expect(response).to redirect_to(edit_practice_path(practice))
        expect(flash[:alert]).to be_present
      end
    end

    context "when signed in as a non-admin member" do
      let(:member) { create(:another_user, organization: organization, practices: [practice]) }

      before do
        delete session_path
        sign_in_as(member, attributes_for(:another_user)[:password])
      end

      it "is not authorized" do
        post practice_invitations_path(practice), params: valid_params
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end
  end

  describe "DELETE /practices/:practice_id/invitations/:id" do
    let!(:invitation) { create(:invitation, practice: practice, invited_by: admin, email: "newuser@example.com") }

    it "destroys the invitation" do
      expect { delete practice_invitation_path(practice, invitation) }
        .to change { practice.invitations.count }.by(-1)
    end

    it "redirects to the practice edit page with a notice" do
      delete practice_invitation_path(practice, invitation)
      expect(response).to redirect_to(edit_practice_path(practice))
      expect(flash[:notice]).to include("cancelled")
    end

    context "when signed in as a non-admin member" do
      let(:member) { create(:another_user, organization: organization, practices: [practice]) }

      before do
        delete session_path
        sign_in_as(member, attributes_for(:another_user)[:password])
      end

      it "is not authorized" do
        delete practice_invitation_path(practice, invitation)
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end
  end
end
