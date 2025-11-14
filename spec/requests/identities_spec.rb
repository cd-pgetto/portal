require "rails_helper"

RSpec.describe "Identities", type: :request do
  describe "GET /create" do
    let!(:google_provider) { IdentityProvider.find_by(strategy: "google_oauth2") || create(:google_identity_provider) }
    let!(:perceptive) { Organization.find_by(subdomain: "perceptive") || create(:perceptive) }
    let(:perceptive_email_domain) { attributes_for(:perceptive_io_email_domain)[:domain_name] }

    before do
      OmniAuth.configure do |config|
        config.test_mode = true
        config.mock_auth[:google_oauth2] =
          OmniAuth::AuthHash.new(
            {provider: "google_oauth2", uid: "123456789",
             info: {first_name: "John", last_name: "Doe", image: "", email: "john.doe@#{perceptive_email_domain}"},
             extra: {id_info: {hd: perceptive_email_domain}}}
          )
      end
    end

    context "with a new user" do
      it "creates new user and identity, signs in and redirects to user" do
        expect do
          expect do
            get "/oauth/google_oauth2/callback"
          end.to change(Identity, :count)
        end.to change(User, :count)

        # expect(session[:auth_token]).to eq(User.last.auth_token)
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(home_path)
      end
    end

    context "with an existing identity" do
      it "signs in and redirects to user without creating new records" do
        user = create_internal_user
        create(:identity, user: user, identity_provider: google_provider, provider_user_id: "123456789")

        expect do
          expect do
            get "/oauth/google_oauth2/callback"
          end.not_to change(Identity, :count)
        end.not_to change(User, :count)

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(home_path)
      end
    end
  end
end
