require "test_helper"

class SessionsNewTest < ActionView::TestCase
  describe "sign in step 1 - email form" do
    before {
      render Views::Sessions::New.new(email_address: "", identity_providers: [], password_auth_allowed: true)
    }

    it "has a logo image" do
      assert_select "img.theme-dark[src*='perceptive-lockup-white']"
      assert_select "img.theme-light[src*='perceptive-lockup-dark']"
    end

    it "has a title" do
      assert_includes rendered, "Sign In"
    end

    it "has a form" do
      assert_select "form[action='#{session_path}'][method='post']"
    end

    it "requires an email address" do
      assert_select "form label[for='email_address']", "Email address"
      assert_select "form input[type='email'][required][autofocus]#email_address"
    end

    it "does not show the password field at step 1" do
      assert_select "form label[for='password']", count: 0
      assert_select "form input[type='password']", count: 0
    end

    it "has a submit button labeled Next" do
      assert_select "form input[type='submit'][value='Next']"
    end

    it "does not target the top frame" do
      assert_select "form[data-turbo-frame='_top']", count: 0
    end
  end

  describe "sign in step 2 without identity providers" do
    before {
      render Views::Sessions::New.new(email_address: "test@example.com", identity_providers: [], password_auth_allowed: true)
    }

    it "has a logo image" do
      assert_select "img.theme-dark[src*='perceptive-lockup-white']"
    end

    it "has a title" do
      assert_includes rendered, "Sign In"
    end

    it "has a form" do
      assert_select "form[action='#{session_path}'][method='post']"
    end

    it "requires a password" do
      assert_select "form label[for='password']", "Password"
      assert_select "form input[type='password'][required]#password"
    end

    it "has a submit button labeled Sign In" do
      assert_select "form input[type='submit'][value='Sign In']"
    end

    it "targets the top frame" do
      assert_select "form[data-turbo-frame='_top']"
    end
  end

  describe "sign in step 2 with an identity provider" do
    let(:idp) { IdentityProvider.find_by(strategy: :google_oauth2) || create(:google_identity_provider) }

    before {
      idp
      render Views::Sessions::New.new(email_address: "test@example.com",
        identity_providers: [idp], password_auth_allowed: true)
    }

    it "has a button to sign in with the identity provider" do
      assert_select "form button[type='submit']"
      assert_select "form button img[src*='google-oauth2-icon']"
      assert_select "form button span", "Sign In with Google OAuth"
    end

    it "has a divider" do
      assert_select "span.divider", "OR"
    end
  end

  describe "sign in step 2 with an identity provider and password auth not allowed" do
    let(:idp) { IdentityProvider.find_by(strategy: :google_oauth2) || create(:google_identity_provider) }

    before {
      idp
      render Views::Sessions::New.new(email_address: "test@example.com",
        identity_providers: [idp], password_auth_allowed: false)
    }

    it "does not render a password form" do
      assert_select "form[action='#{session_path}'][method='post']", count: 0
    end

    it "does not render password fields" do
      assert_select "form label[for='email_address']", count: 0
      assert_select "form input[type='email'][required]", count: 0
    end

    it "does not render a sign in submit button" do
      assert_select "form input[type='submit'][value='Sign In']", count: 0
    end
  end
end
