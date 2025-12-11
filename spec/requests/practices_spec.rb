require "rails_helper"

RSpec.describe "Practices", type: :request do
  context "when signed in as a practice member" do
    let(:organization) { create(:organization) }
    let(:practice) { create(:practice, name: "Practice Name", organization: organization) }
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
