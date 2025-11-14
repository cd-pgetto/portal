require "rails_helper"

RSpec.describe "/passwords", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  describe "GET /passwords/new" do
    it "renders a successful response" do
      get new_password_url
      expect(response).to be_successful
    end
  end

  describe "POST /passwords" do
    context "with a valid email address" do
      it "sends a password reset email" do
        expect {
          post passwords_url, params: {email_address: user.email_address}
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with("PasswordsMailer", "reset", "deliver_now", {args: [user]})
      end

      it "redirects to sign in page with a notice" do
        post passwords_url, params: {email_address: user.email_address}

        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end

      it "does not reveal whether the email exists" do
        post passwords_url, params: {email_address: user.email_address}

        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end
    end

    context "with an invalid email address" do
      it "does not send a password reset email" do
        expect {
          post passwords_url, params: {email_address: "nonexistent@example.com"}
        }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it "redirects to sign in page with the same notice" do
        post passwords_url, params: {email_address: "nonexistent@example.com"}

        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end

      it "does not reveal that the email does not exist" do
        post passwords_url, params: {email_address: "nonexistent@example.com"}

        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end
    end

    context "with a blank email address" do
      it "does not send a password reset email" do
        expect {
          post passwords_url, params: {email_address: ""}
        }.not_to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end

      it "redirects to sign in page with a notice" do
        post passwords_url, params: {email_address: ""}

        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
      end
    end
  end

  describe "GET /passwords/:token/edit" do
    let!(:token) { user.generate_token_for(:password_reset) }

    context "with a valid token" do
      it "renders a successful response" do
        get edit_password_url(token)
        expect(response).to be_successful
      end
    end

    context "with an invalid token" do
      it "redirects to new password page with an alert" do
        get edit_password_url("invalid_token")

        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end
    end

    context "with an expired token" do
      it "redirects to new password page with an alert" do
        # Generate token and then travel to future to expire it (tokens expire after 15 minutes)
        expired_token = token
        travel 20.minutes do
          get edit_password_url(expired_token)

          expect(response).to redirect_to(new_password_path)
          expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
        end
      end
    end
  end

  describe "PATCH /passwords/:token" do
    let!(:token) { user.generate_token_for(:password_reset) }
    let(:new_password) { "NewSecurePassword123!" }

    context "with valid matching passwords" do
      it "updates the user's password" do
        patch password_url(token), params: {password: new_password, password_confirmation: new_password}

        user.reload
        expect(user.authenticate(new_password)).to eq(user)
      end

      it "redirects to sign in page with a notice" do
        patch password_url(token), params: {password: new_password, password_confirmation: new_password}

        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq("Password has been reset.")
      end

      it "allows the user to sign in with the new password" do
        patch password_url(token), params: {password: new_password, password_confirmation: new_password}

        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: new_password}
        expect(response).to redirect_to(home_path)
      end
    end

    context "with an invalid token" do
      it "redirects to new password page with an alert" do
        patch password_url("invalid_token"), params: {password: new_password, password_confirmation: new_password}

        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
      end

      it "does not update any user's password" do
        old_password_digest = user.password_digest

        patch password_url("invalid_token"), params: {password: new_password, password_confirmation: new_password}

        user.reload
        expect(user.password_digest).to eq(old_password_digest)
      end
    end

    context "with an expired token" do
      it "redirects to new password page with an alert" do
        expired_token = token
        travel 20.minutes do
          patch password_url(expired_token), params: {password: new_password, password_confirmation: new_password}

          expect(response).to redirect_to(new_password_path)
          expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
        end
      end

      it "does not update the user's password" do
        old_password_digest = user.password_digest
        expired_token = token
        travel 20.minutes do
          patch password_url(expired_token), params: {password: new_password, password_confirmation: new_password}

          user.reload
          expect(user.password_digest).to eq(old_password_digest)
        end
      end
    end

    context "with a password that is too short" do
      it "does not update the user's password" do
        old_password_digest = user.password_digest
        short_password = "short"

        patch password_url(token), params: {password: short_password, password_confirmation: short_password}

        user.reload
        expect(user.password_digest).to eq(old_password_digest)
      end
    end
  end

  describe "security considerations" do
    it "generates secure tokens" do
      token = user.generate_token_for(:password_reset)

      expect(token).to be_present
      expect(token.length).to be > 20
    end

    it "tokens are user-specific and cannot be used for other users" do
      other_user = create(:user, email_address: "other@example.com")
      token = user.generate_token_for(:password_reset)

      # Trying to use user's token for other_user should fail
      expect {
        User.find_by_password_reset_token!(token)
      }.not_to raise_error

      # The token should only work for the user it was generated for
      found_user = User.find_by_password_reset_token!(token)
      expect(found_user).to eq(user)
      expect(found_user).not_to eq(other_user)
    end
  end
end
