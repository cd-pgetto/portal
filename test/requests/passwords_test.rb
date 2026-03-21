require "test_helper"

class PasswordsTest < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:another_user) }

  describe "GET /passwords/new" do
    it "renders a successful response" do
      get new_password_url
      assert_response :success
    end
  end

  describe "POST /passwords" do
    describe "with a valid email address" do
      it "sends a password reset email" do
        assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
          post passwords_url, params: {email_address: user.email_address}
        end
      end

      it "redirects to sign in page with a notice" do
        post passwords_url, params: {email_address: user.email_address}
        assert_redirected_to new_session_path
        assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
      end

      it "does not reveal whether the email exists" do
        post passwords_url, params: {email_address: user.email_address}
        assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
      end
    end

    describe "with an invalid email address" do
      it "does not send a password reset email" do
        assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          post passwords_url, params: {email_address: "nonexistent@example.com"}
        end
      end

      it "redirects to sign in page with the same notice" do
        post passwords_url, params: {email_address: "nonexistent@example.com"}
        assert_redirected_to new_session_path
        assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
      end
    end

    describe "with a blank email address" do
      it "does not send a password reset email" do
        assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
          post passwords_url, params: {email_address: ""}
        end
      end

      it "redirects to sign in page with a notice" do
        post passwords_url, params: {email_address: ""}
        assert_redirected_to new_session_path
        assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
      end
    end
  end

  describe "GET /passwords/:token/edit" do
    let(:token) { user.generate_token_for(:password_reset) }
    before { token }

    describe "with a valid token" do
      it "renders a successful response" do
        get edit_password_url(token)
        assert_response :success
      end
    end

    describe "with an invalid token" do
      it "redirects to new password page with an alert" do
        get edit_password_url("invalid_token")
        assert_redirected_to new_password_path
        assert_equal "Password reset link is invalid or has expired.", flash[:alert]
      end
    end

    describe "with an expired token" do
      it "redirects to new password page with an alert" do
        expired_token = token
        travel 20.minutes do
          get edit_password_url(expired_token)
          assert_redirected_to new_password_path
          assert_equal "Password reset link is invalid or has expired.", flash[:alert]
        end
      end
    end
  end

  describe "PATCH /passwords/:token" do
    let(:token) { user.generate_token_for(:password_reset) }
    let(:new_password) { "NewSecurePassword123!" }
    before { token }

    describe "with valid matching passwords" do
      it "updates the user's password" do
        patch password_url(token), params: {password: new_password, password_confirmation: new_password}
        user.reload
        assert_equal user, user.authenticate(new_password)
      end

      it "redirects to sign in page with a notice" do
        patch password_url(token), params: {password: new_password, password_confirmation: new_password}
        assert_redirected_to new_session_path
        assert_equal "Password has been reset.", flash[:notice]
      end

      it "allows the user to sign in with the new password" do
        patch password_url(token), params: {password: new_password, password_confirmation: new_password}
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: new_password}
        assert_redirected_to home_path
      end
    end

    describe "with an invalid token" do
      it "redirects to new password page with an alert" do
        patch password_url("invalid_token"), params: {password: new_password, password_confirmation: new_password}
        assert_redirected_to new_password_path
        assert_equal "Password reset link is invalid or has expired.", flash[:alert]
      end

      it "does not update any user's password" do
        old_digest = user.password_digest
        patch password_url("invalid_token"), params: {password: new_password, password_confirmation: new_password}
        user.reload
        assert_equal old_digest, user.password_digest
      end
    end

    describe "with an expired token" do
      it "redirects to new password page with an alert" do
        expired_token = token
        travel 20.minutes do
          patch password_url(expired_token), params: {password: new_password, password_confirmation: new_password}
          assert_redirected_to new_password_path
          assert_equal "Password reset link is invalid or has expired.", flash[:alert]
        end
      end

      it "does not update the user's password" do
        old_digest = user.password_digest
        expired_token = token
        travel 20.minutes do
          patch password_url(expired_token), params: {password: new_password, password_confirmation: new_password}
          user.reload
          assert_equal old_digest, user.password_digest
        end
      end
    end

    describe "with a password that is too short" do
      it "does not update the user's password" do
        old_digest = user.password_digest
        patch password_url(token), params: {password: "short", password_confirmation: "short"}
        user.reload
        assert_equal old_digest, user.password_digest
      end
    end
  end

  describe "security considerations" do
    it "generates secure tokens" do
      token = user.generate_token_for(:password_reset)
      assert_not_nil token
      assert token.length > 20
    end

    it "tokens are user-specific" do
      other_user = create(:another_user)
      token = user.generate_token_for(:password_reset)
      found_user = User.find_by_password_reset_token!(token)
      assert_equal user, found_user
      assert_not_equal other_user, found_user
    end
  end
end
