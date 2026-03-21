require "test_helper"

class IdentitiesTest < ActionDispatch::IntegrationTest
  describe "GET /oauth/:provider/callback" do
    let(:google_provider) { IdentityProvider.find_by(strategy: "google_oauth2") || create(:google_identity_provider) }
    let(:perceptive) { Organization.find_by(subdomain: "perceptive") || create(:perceptive) }
    let(:perceptive_email_domain) { attributes_for(:perceptive_io_email_domain)[:domain_name] }

    before {
      google_provider
      perceptive
      OmniAuth.configure do |config|
        config.test_mode = true
        config.mock_auth[:google_oauth2] =
          OmniAuth::AuthHash.new(
            {provider: "google_oauth2", uid: "123456789",
             info: {first_name: "John", last_name: "Doe", image: "", email: "john.doe@#{perceptive_email_domain}"},
             extra: {id_info: {hd: perceptive_email_domain}}}
          )
      end
    }

    describe "with a new user" do
      it "creates new user and identity, signs in and redirects to user" do
        assert_difference -> { Identity.count }, 1 do
          assert_difference -> { User.count }, 1 do
            get "/oauth/google_oauth2/callback"
          end
        end
        assert response.redirect?
        assert_redirected_to home_path
      end
    end

    describe "with an existing identity" do
      it "signs in without creating new records" do
        user = create(:another_user)
        create(:organization_member, organization: perceptive, user: user)
        create(:identity, user: user, identity_provider: google_provider, provider_user_id: "123456789")

        assert_no_difference -> { Identity.count } do
          assert_no_difference -> { User.count } do
            get "/oauth/google_oauth2/callback"
          end
        end
        assert_redirected_to home_path
      end
    end
  end

  describe "GET /oauth/failure" do
    it "redirects to sign in with alert" do
      get "/oauth/failure"
      assert_redirected_to new_session_path
      follow_redirect!
      assert_includes response.body, "Authentication failed."
    end
  end
end
