require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  describe "GET /home" do
    it "redirects to sign in when not authenticated" do
      get "/home"
      assert response.redirect?
    end

    describe "signed in as system admin" do
      before { sign_in_as_admin }

      it "redirects to admin dashboard" do
        get "/home"
        assert_redirected_to admin_dashboard_path
      end
    end

    describe "signed in as regular user" do
      let(:user) { create(:another_user) }
      before { sign_in_as(user, USER_PASSWORD) }

      it "renders the home page" do
        get "/home"
        assert_response :ok
      end
    end
  end
end
