require "rails_helper"

RSpec.describe "Practices", type: :request do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, name: "Practice Name", organization: organization) }

  context "when not signed in" do
    it "redirects to sign in" do
      get practices_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in as a non-member" do
    let(:other_user) { create(:another_user) }

    before { sign_in_as(other_user, attributes_for(:another_user)[:password]) }

    it "is not authorized to access the index" do
      get practices_path
      expect(response).to redirect_to(home_path)
      expect(flash[:alert]).to include("not authorized")
    end

    it "cannot find a practice they are not a member of" do
      get practice_path(practice)
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when signed in as a practice member" do
    let(:user) { create(:user, organization: organization, practices: [practice]) }

    before { sign_in_as(user, attributes_for(:user)[:password]) }

    describe "GET /practices" do
      it "returns success" do
        get practices_path
        expect(response).to have_http_status(:success)
      end

      it "only lists practices the user belongs to" do
        other_practice = create(:practice, organization: organization)
        get practices_path
        expect(response.body).to include("Practice Name")
        expect(response.body).not_to include(other_practice.name)
      end
    end

    describe "GET /practices/:id" do
      it "returns success" do
        get practice_path(practice)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /practices/:id/edit" do
      it "is not authorized for a regular member" do
        get edit_practice_path(practice)
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end

    describe "PATCH /practices/:id" do
      it "is not authorized for a regular member" do
        patch practice_path(practice), params: {practice: {name: "New Name"}}
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("not authorized")
        expect(practice.reload.name).to eq("Practice Name")
      end
    end

    describe "POST /practices/:id/select" do
      it "sets the current practice and redirects to it" do
        post select_practice_path(practice)
        expect(response).to redirect_to(practice_path(practice))
      end

      it "returns 404 when the practice does not exist" do
        post select_practice_path("00000000-0000-0000-0000-000000000000")
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 when the practice belongs to another user" do
        other_practice = create(:practice, organization: organization)
        post select_practice_path(other_practice)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context "when signed in as a practice admin" do
    let(:admin) { create(:user, organization: organization, practices: [practice]) }

    before do
      admin.practice_memberships.find_by(practice: practice).update!(role: :admin)
      sign_in_as(admin, attributes_for(:user)[:password])
    end

    describe "GET /practices/:id/edit" do
      it "returns success" do
        get edit_practice_path(practice)
        expect(response).to have_http_status(:success)
      end
    end

    describe "PATCH /practices/:id" do
      context "with valid params" do
        it "updates the practice name and redirects to show" do
          patch practice_path(practice), params: {practice: {name: "Updated Name"}}
          expect(response).to redirect_to(practice_path(practice))
          expect(flash[:notice]).to include("successfully updated")
          expect(practice.reload.name).to eq("Updated Name")
        end
      end

      context "with invalid params" do
        it "re-renders the edit form with an error" do
          patch practice_path(practice), params: {practice: {name: ""}}
          expect(response).to have_http_status(:unprocessable_content)
          expect(flash[:alert]).to include("could not be updated")
          expect(practice.reload.name).to eq("Practice Name")
        end
      end
    end
  end
end
