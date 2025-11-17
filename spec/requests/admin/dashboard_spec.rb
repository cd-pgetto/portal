require "rails_helper"

RSpec.describe "Admin::Dashboards", type: :request do
  describe "GET /show" do
    context "when signed in as admin" do
      before { sign_in_as_admin }

      it "returns http success" do
        get admin_dashboard_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when signed in as a regular user" do
      before { sign_in_as(create(:user), attributes_for(:user)[:password]) }

      it "redirects to root path" do
        get admin_dashboard_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not signed in" do
      it "redirects to sign in page" do
        get admin_dashboard_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
