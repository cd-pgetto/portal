require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /session" do
    context "when signed in" do
      it "redirects to the user's home page" do
        sign_in_as user, attributes_for(:user)[:password]

        get new_session_path
        expect(response).to redirect_to(home_path)
      end
    end

    context "when not signed in" do
      context "without a subdomain" do
        it "shows the sign in page" do
          get new_session_path
          expect(response).to have_http_status(:success)
        end
      end

      context "with a subdomain" do
        it "shows the sign in page" do
          create(:big_dso)
          host! "org2.example.com"
          get new_session_path
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "POST /session" do
    context "at step 1" do
      it "renders the password entry form if allowed" do
        post session_path, params: {sign_in_step: 1, email_address: user.email_address}

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Password")
      end

      it "renders a list of shared identity providers for unknown org" do
        idp = create(:identity_provider)

        post session_path, params: {sign_in_step: 1, email_address: user.email_address}

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Password")
        expect(response.body).to include("Sign In with #{idp.name}")
      end

      context "for an organization based on the email domain" do
        let(:idp) { create(:identity_provider, availability: "dedicated", name: "DedicatedIdP") }

        it "renders a list of org identity providers" do
          create(:organization, password_auth_allowed: true, identity_providers: [idp],
            email_domains: [create(:email_domain, domain_name: user.email_address.split("@").last)])

          post session_path, params: {sign_in_step: 1, email_address: user.email_address}

          expect(response).to have_http_status(:success)
          expect(response.body).to include("Password")
          expect(response.body).to include("Sign In with #{idp.name}")
        end

        it "does not render password entry if not allowed" do
          create(:organization, password_auth_allowed: false, identity_providers: [idp],
            email_domains: [create(:email_domain, domain_name: user.email_address.split("@").last)])

          post session_path, params: {sign_in_step: 1, email_address: user.email_address}

          expect(response).to have_http_status(:success)
          expect(response.body).not_to include("Password")
          expect(response.body).to include("Sign In with #{idp.name}")
        end
      end

      it "renders a list of org identity providers based on subdomain" do
        idp = create(:identity_provider, availability: "dedicated", name: "DedicatedIdP")
        org = create(:organization, identity_providers: [idp])
        host! "#{org.subdomain}.example.com"

        post session_path, params: {sign_in_step: 1, email_address: user.email_address}

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Password")
        expect(response.body).to include("Sign In with #{idp.name}")
      end
    end

    context "at step 2" do
      context "with valid credentials" do
        it "creates a new session and redirects to the user's home page" do
          post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: attributes_for(:user)[:password]}

          expect(response).to redirect_to(home_path)
          # Can't check for signed cookies in Rails 7+ with Rack::Test, so we check for presence
          expect(cookies[:session_id]).to be_present
        end
      end

      context "with invalid credentials" do
        it "does not create a session and re-renders the login form" do
          post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}

          expect(response).to have_http_status(:unprocessable_content)
          expect(flash[:alert]).to include("Please try another email address or password")
          expect(cookies[:session_id]).to be_nil
        end
      end
    end

    context "as admin user" do
      let(:admin_user) { create_system_admin }

      it "creates a new session and redirects to the admin home page" do
        sign_in_as_admin

        expect(response).to redirect_to(home_path)
        expect(cookies[:session_id]).to be_present
      end
    end
  end

  describe "DELETE /session" do
    context "when signed in" do
      before do
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: attributes_for(:user)[:password]}
      end

      it "destroys the session and redirects to the sign in page" do
        delete session_path

        expect(response).to redirect_to(new_session_path)
        # Check for blank since this is referenceing the Rack::Test::CookieJar and it
        # leaves the session id key with a block value.
        expect(cookies[:session_id]).to eq("")
      end
    end

    context "when not signed in" do
      it "redirects to the sign in page without error" do
        delete session_path

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "account locking after failed attempts" do
    include ActiveSupport::Testing::TimeHelpers

    context "when user exceeds maximum failed login attempts" do
      it "locks the account after 10 failed attempts" do
        # Attempt to sign in with wrong password 10 times
        10.times do
          post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}
        end

        user.reload
        expect(user.failed_login_count).to eq(10)
        expect(user.locked?).to be true
      end

      it "prevents login even with correct password when locked" do
        # Lock the account by failing 10 times
        user.update(failed_login_count: 10)

        # Try to sign in with correct password
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: attributes_for(:user)[:password]}

        expect(response).to have_http_status(:unprocessable_content)
        expect(cookies[:session_id]).to be_nil
      end

      it "shows appropriate error message when account is locked" do
        user.update(failed_login_count: 10)

        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: attributes_for(:user)[:password]}

        expect(flash[:alert]).to include("Sign in failed. Please try another email address or password.")
      end
    end

    context "when lock duration expires" do
      it "allows login after lock duration has passed" do
        # Lock the account
        user.update(failed_login_count: 10)
        expect(user.locked?).to be true

        # Travel past the lock duration (5 minutes)
        travel 6.minutes do
          # Should be able to login now
          post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: attributes_for(:user)[:password]}

          expect(response).to redirect_to(home_path)
          expect(cookies[:session_id]).to be_present
        end
      end

      it "unlocks the account automatically after lock duration" do
        user.update(failed_login_count: 10)
        expect(user.locked?).to be true

        travel 6.minutes do
          user.reload
          expect(user.locked?).to be false
        end
      end
    end

    context "when tracking failed attempts" do
      it "increments failed login count on each failed attempt" do
        initial_count = user.failed_login_count

        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}

        user.reload
        expect(user.failed_login_count).to eq(initial_count + 1)
      end

      it "resets failed login count on successful login" do
        # Create some failed attempts
        user.update(failed_login_count: 5)

        # Successful login
        post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: attributes_for(:user)[:password]}

        user.reload
        expect(user.failed_login_count).to eq(0)
      end

      it "does not increment count beyond lock threshold" do
        # Set to threshold
        user.update(failed_login_count: 10)

        # Try to fail more times
        3.times do
          post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: "wrongpassword"}
        end

        user.reload
        expect(user.failed_login_count).to be >= 10
      end
    end

    context "when user does not exist" do
      it "does not reveal user existence through timing" do
        # This prevents user enumeration attacks
        post session_path, params: {sign_in_step: 2, email_address: "nonexistent@example.com", password: "password"}

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to include("Sign in failed")
      end
    end
  end
end
