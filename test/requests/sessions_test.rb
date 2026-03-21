require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:another_user) }

  describe "GET /session/new" do
    describe "when signed in" do
      before { sign_in_as(user, USER_PASSWORD) }

      it "redirects to the user's home page" do
        get new_session_path
        assert_redirected_to home_path
      end
    end

    describe "when not signed in" do
      it "shows the sign in page without a subdomain" do
        get new_session_path
        assert_response :success
      end

      it "shows the sign in page with a subdomain" do
        org = create(:organization)
        host! "#{org.subdomain}.example.com"
        get new_session_path
        assert_response :success
      end
    end
  end

  describe "POST /session" do
    describe "at step 1" do
      it "renders the password entry form if allowed" do
        post session_path, params: {sign_in_step: 1, email_address: user.email_address}
        assert_response :success
        assert_includes response.body, "Password"
      end

      it "renders a list of shared identity providers for unknown org" do
        idp = create(:identity_provider)
        post session_path, params: {sign_in_step: 1, email_address: user.email_address}
        assert_response :success
        assert_includes response.body, "Sign In with #{idp.name}"
      end

      describe "for an organization based on the email domain" do
        let(:idp) { create(:identity_provider, name: "OrgIdP") }
        let(:email_domain_name) { user.email_address.split("@").last }

        it "renders a list of org identity providers" do
          org = create(:organization, password_auth_allowed: true,
            email_domains: [create(:email_domain, domain_name: email_domain_name)])
          org.shared_identity_providers << idp
          post session_path, params: {sign_in_step: 1, email_address: user.email_address}
          assert_response :success
          assert_includes response.body, "Password"
          assert_includes response.body, "Sign In with #{idp.name}"
        end

        it "does not render password entry if not allowed" do
          org = create(:organization, password_auth_allowed: true,
            email_domains: [create(:email_domain, domain_name: email_domain_name)])
          org.shared_identity_providers << idp
          org.update!(password_auth_allowed: false)
          post session_path, params: {sign_in_step: 1, email_address: user.email_address}
          assert_response :success
          assert_not_includes response.body, "Password"
          assert_includes response.body, "Sign In with #{idp.name}"
        end
      end

      it "renders org identity providers based on subdomain" do
        idp = create(:identity_provider, name: "SubdomainOrgIdP")
        org = create(:organization)
        org.shared_identity_providers << idp
        host! "#{org.subdomain}.example.com"
        post session_path, params: {sign_in_step: 1, email_address: user.email_address}
        assert_response :success
        assert_includes response.body, "Sign In with #{idp.name}"
      end
    end

    describe "at step 2 with valid credentials" do
      it "creates a new session and redirects to the user's home page" do
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: USER_PASSWORD}
        assert_redirected_to home_path
        assert_not_nil cookies[:session_id]
      end
    end

    describe "at step 2 with invalid credentials" do
      it "does not create a session and re-renders the login form" do
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}
        assert_response :unprocessable_content
        assert_includes flash[:alert], "Please try another email address or password"
        assert_nil cookies[:session_id]
      end
    end

    describe "as admin user" do
      it "creates a new session and redirects to the home page" do
        sign_in_as_admin
        assert_redirected_to home_path
        assert_not_nil cookies[:session_id]
      end
    end
  end

  describe "DELETE /session" do
    describe "when signed in" do
      before { post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: USER_PASSWORD} }

      it "destroys the session and redirects to sign in page" do
        delete session_path
        assert_redirected_to new_session_path
        assert_equal "", cookies[:session_id]
      end
    end

    describe "when not signed in" do
      it "redirects to the sign in page without error" do
        delete session_path
        assert_redirected_to new_session_path
      end
    end
  end

  describe "account locking after failed attempts" do
    it "locks the account after 10 failed attempts" do
      10.times do
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}
      end
      user.reload
      assert_equal 10, user.failed_login_count
      assert user.locked?
    end

    it "prevents login even with correct password when locked" do
      user.update(failed_login_count: 10)
      post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: USER_PASSWORD}
      assert_response :unprocessable_content
      assert_nil cookies[:session_id]
    end

    it "shows appropriate error message when account is locked" do
      user.update(failed_login_count: 10)
      post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: USER_PASSWORD}
      assert_includes flash[:alert], "Sign in failed."
    end

    it "allows login after lock duration has passed" do
      user.update(failed_login_count: 10)
      travel 6.minutes do
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: USER_PASSWORD}
        assert_redirected_to home_path
        assert_not_nil cookies[:session_id]
      end
    end

    it "unlocks the account automatically after lock duration" do
      user.update(failed_login_count: 10)
      assert user.locked?
      travel 6.minutes do
        user.reload
        assert_not user.locked?
      end
    end

    it "increments failed login count on each failed attempt" do
      initial_count = user.failed_login_count
      post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}
      user.reload
      assert_equal initial_count + 1, user.failed_login_count
    end

    it "resets failed login count on successful login" do
      user.update(failed_login_count: 5)
      post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: USER_PASSWORD}
      user.reload
      assert_equal 0, user.failed_login_count
    end

    it "does not increment count beyond lock threshold" do
      user.update(failed_login_count: 10)
      3.times do
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}
      end
      user.reload
      assert user.failed_login_count >= 10
    end

    it "does not reveal user existence for nonexistent user" do
      post session_path, params: {sign_in_step: 2, email_address: "nonexistent@example.com", password: "password"}
      assert_response :unprocessable_content
      assert_includes flash[:alert], "Sign in failed"
    end
  end
end
