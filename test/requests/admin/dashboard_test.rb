require "test_helper"

class Admin::DashboardTest < ActionDispatch::IntegrationTest
  describe "GET /admin/dashboard" do
    describe "signed in as admin" do
      before { sign_in_as_admin }

      it "returns http success" do
        get admin_dashboard_path
        assert_response :success
      end
    end

    describe "signed in as a regular user" do
      let(:user) { create(:another_user) }
      before { sign_in_as(user, USER_PASSWORD) }

      it "redirects to root path" do
        get admin_dashboard_path
        assert_redirected_to root_path
      end
    end

    describe "not signed in" do
      it "redirects to sign in page" do
        get admin_dashboard_path
        assert_redirected_to new_session_path
      end
    end
  end
end
