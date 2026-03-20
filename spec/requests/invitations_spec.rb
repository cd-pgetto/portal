require "rails_helper"

RSpec.describe "Invitations", type: :request do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:inviter) { create(:user, organization: organization, practices: [practice]) }
  let(:invitation) { create(:invitation, practice: practice, invited_by: inviter, email: "newuser@example.com") }
  let(:token) { invitation.generate_token_for(:acceptance) }

  describe "GET /invitations/:token" do
    context "with a valid pending invitation" do
      it "renders the invitation landing page" do
        get invitation_path(token)
        expect(response).to have_http_status(:success)
      end

      it "stores the token in session" do
        get invitation_path(token)
        expect(session[:invitation_token]).to eq(token)
      end
    end

    context "with an invalid token" do
      it "redirects to root with an alert" do
        get invitation_path("invalid-token")
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("invalid or has expired")
      end
    end

    context "with an expired invitation" do
      let(:invitation) { create(:invitation, :expired, practice: practice, invited_by: inviter, email: "newuser@example.com") }

      it "redirects to root with an alert" do
        get invitation_path(token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("invalid or has expired")
      end
    end

    context "with an already accepted invitation" do
      let(:invitation) { create(:invitation, :accepted, practice: practice, invited_by: inviter, email: "newuser@example.com") }

      it "redirects to root with an alert" do
        get invitation_path(token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("invalid or has expired")
      end
    end
  end

  describe "PATCH /invitations/:token/accept" do
    context "when not signed in" do
      it "redirects to sign in" do
        patch accept_invitation_path(token)
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when signed in as the invited user" do
      let(:invited_user) { create(:user, email_address: "newuser@example.com") }

      before { sign_in_as(invited_user, attributes_for(:user)[:password]) }

      it "accepts the invitation and redirects to the practice" do
        patch accept_invitation_path(token)
        expect(response).to redirect_to(practice_path(practice))
        expect(flash[:notice]).to include("You have joined")
      end

      it "creates a practice membership for the user" do
        expect { patch accept_invitation_path(token) }
          .to change { PracticeMember.where(practice: practice, user: invited_user).count }.by(1)
      end

      it "creates an organization membership for the user" do
        expect { patch accept_invitation_path(token) }
          .to change { OrganizationMember.where(organization: organization, user: invited_user).count }.by(1)
      end

      it "marks the invitation as accepted" do
        patch accept_invitation_path(token)
        expect(invitation.reload.accepted?).to be true
      end
    end

    context "when signed in as a different user" do
      let(:other_user) { create(:another_user) }

      before { sign_in_as(other_user, attributes_for(:user)[:password]) }

      it "redirects back to the invitation with an alert" do
        patch accept_invitation_path(token)
        expect(response).to redirect_to(invitation_path(token))
        expect(flash[:alert]).to include("newuser@example.com")
      end

      it "does not accept the invitation" do
        patch accept_invitation_path(token)
        expect(invitation.reload.accepted?).to be false
      end
    end

    context "with an expired invitation" do
      let(:invitation) { create(:invitation, :expired, practice: practice, invited_by: inviter, email: "newuser@example.com") }

      let(:invited_user) { create(:user, email_address: "newuser@example.com") }

      before { sign_in_as(invited_user, attributes_for(:user)[:password]) }

      it "redirects to root with an alert" do
        patch accept_invitation_path(token)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to include("invalid or has expired")
      end
    end
  end

  describe "invitation acceptance via sign in" do
    let(:existing_user) { create(:user, email_address: "newuser@example.com") }

    it "accepts the invitation after signing in with the invited email" do
      get invitation_path(token)

      post session_path, params: {
        sign_in_step: 2,
        email_address: existing_user.email_address,
        password: attributes_for(:user)[:password]
      }

      expect(response).to redirect_to(practice_path(practice))
      expect(invitation.reload.accepted?).to be true
      expect(PracticeMember.where(practice: practice, user: existing_user)).to exist
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
      expect(response).to redirect_to(practice_path(practice))
      expect(invitation.reload.accepted?).to be true
      expect(PracticeMember.where(practice: practice, user: new_user)).to exist
    end
  end
end
