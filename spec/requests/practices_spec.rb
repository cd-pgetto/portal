require "rails_helper"

RSpec.describe "Practices", type: :request do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, name: "Practice Name", organization: organization) }

  context "when not signed in" do
    it "redirects to sign in page" do
      get practices_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in as a non-practice member" do
    let(:other_user) { create(:another_user) }

    before { sign_in_as(other_user, attributes_for(:user)[:password]) }

    it "is not authorized to access the index" do
      get practices_path
      expect(response).to redirect_to(home_path)
      expect(flash[:alert]).to include("You are not authorized")
    end

    it "cannot find a practice they are not a member of" do
      get practice_path(practice)
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when signed in as a practice member" do
    let(:user) { create(:user, organization: organization, practices: [practice]) }

    before { sign_in_as(user, attributes_for(:user)[:password]) }

    describe "GET /index" do
      it "returns http success" do
        get practices_path
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /show" do
      it "returns http success" do
        get practice_path(practice)
        expect(response).to have_http_status(:success)
      end
    end

    describe "GET /edit" do
      it "returns http success" do
        get edit_practice_path(practice)
        expect(response).to have_http_status(:redirect)
      end
    end

    describe "GET /update" do
      it "returns http success" do
        put practice_path(practice), params: {practice: {name: "New Practice Name"}}
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(home_path)
        expect(practice.reload.name).to eq("Practice Name")
      end
    end

    describe "GET /select" do
      it "returns http success" do
        post select_practice_path(practice)
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(practice_path(practice))
      end
    end
  end
end
