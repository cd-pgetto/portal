require "rails_helper"

RSpec.describe "Homes", type: :request do
  describe "GET /home" do
    context "when user is not authenticated" do
      it "redirects to sign in page" do
        get "/home"
        expect(response).to have_http_status(:redirect)
      end
    end

    context "when user is authenticated as system admin" do
      let(:system_admin) { create(:user, :system_admin) }

      before { sign_in_as_admin }

      it "redirects to admin dashboard" do
        get "/home"
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    context "when user is authenticated as regular user" do
      let(:regular_user) { create(:user) }

      before { sign_in_as regular_user, attributes_for(:user)[:password] }

      it "renders the home show page" do
        get "/home"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
