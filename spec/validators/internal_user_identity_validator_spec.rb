require "rails_helper"

RSpec.describe InternalUserIdentityValidator, type: :model do
  let(:validator) { described_class.new }
  let(:perceptive_org) { create(:perceptive) }

  describe "#validate" do
    context "when user is not internal" do
      let(:user) { build(:user) }

      it "does not add errors for non-internal users" do
        validator.validate(user)
        expect(user.errors[:identities]).to be_empty
      end

      it "allows non-internal users without any oauth identities" do
        user.save
        expect(user).to be_valid
        expect(user.identities).to be_empty
      end

      it "allows non-internal users with non-Google oauth identities" do
        user.save
        non_google_provider = create(:identity_provider, strategy: "github")
        user.identities.create(identity_provider: non_google_provider, provider_user_id: "github_123")

        validator.validate(user)
        expect(user.errors[:identities]).to be_empty
      end
    end

    context "when user is internal" do
      let(:user) { build(:user) }

      before do
        # Make the user internal by associating with Perceptive organization
        user.save
        user.create_organization_membership(organization: perceptive_org, role: :member)
        user.reload
      end

      context "without any oauth identities" do
        it "adds errors" do
          validator.validate(user)
          expect(user.errors[:identities]).not_to be_empty
        end

        it "does not allow internal users to exist without oauth identities" do
          expect(user.identities).to be_empty
          expect(user).not_to be_valid
        end
      end

      context "with Google OAuth identity" do
        before do
          google_provider = IdentityProvider.find_by(strategy: "google_oauth2") ||
            create(:google_identity_provider)
          user.identities.create!(identity_provider: google_provider, provider_user_id: "google_123")
        end

        it "does not add errors" do
          validator.validate(user)
          expect(user.errors[:identities]).to be_empty
        end

        it "is valid with google_oauth2 strategy" do
          expect(user).to be_valid
        end

        it "allows the user to have the correct oauth identity" do
          expect(user.identities.count).to eq(1)
          expect(user.identities.first.identity_provider.strategy).to eq("google_oauth2")
        end
      end

      context "with non-Google OAuth identity" do
        let(:github_provider) do
          create(:identity_provider,
            strategy: "github",
            name: "GitHub",
            client_id: "github_client_id",
            client_secret: "github_secret")
        end

        before do
          user.identities.create!(identity_provider: github_provider, provider_user_id: "github_123")
        end

        it "adds an error to identities" do
          validator.validate(user)
          expect(user.errors[:identities]).to include("must use Google authentication")
        end

        it "is invalid when using non-Google oauth provider" do
          expect(user).not_to be_valid
          expect(user.errors.full_messages).to include("Identities must use Google authentication")
        end

        it "identifies the oauth identity has the wrong strategy" do
          expect(user.identities.first.identity_provider.strategy).to eq("github")
          expect(user.identities.first.identity_provider.strategy).not_to eq("google_oauth2")
        end
      end

      context "with multiple OAuth identities including one non-Google" do
        let(:google_provider) do
          IdentityProvider.find_by(strategy: "google_oauth2") ||
            create(:google_identity_provider)
        end

        let(:azure_provider) do
          create(:identity_provider,
            strategy: "azure_oauth2",
            name: "Azure AD",
            client_id: "azure_client_id",
            client_secret: "azure_secret")
        end

        before do
          user.identities.create!(identity_provider: google_provider, provider_user_id: "google_123")
          user.identities.create!(identity_provider: azure_provider, provider_user_id: "azure_456")
        end

        it "is valid when at least one identity is Google" do
          # The validator checks if NONE are google_oauth2, so having at least one Google should pass
          validator.validate(user)
          expect(user.errors[:identities]).to be_empty
        end

        it "allows internal users with Google plus other oauth identities" do
          expect(user).to be_valid
          expect(user.identities.count).to eq(2)
        end
      end

      context "with only non-Google OAuth identities" do
        let(:facebook_provider) do
          create(:identity_provider,
            strategy: "facebook",
            name: "Facebook",
            client_id: "fb_client_id",
            client_secret: "fb_secret")
        end

        let(:twitter_provider) do
          create(:identity_provider,
            strategy: "twitter",
            name: "Twitter",
            client_id: "tw_client_id",
            client_secret: "tw_secret")
        end

        before do
          user.identities.create!(identity_provider: facebook_provider, provider_user_id: "fb_123")
          user.identities.create!(identity_provider: twitter_provider, provider_user_id: "tw_456")
        end

        it "adds an error when none of the identities are Google" do
          validator.validate(user)
          expect(user.errors[:identities]).to include("must use Google authentication")
        end

        it "is invalid with multiple non-Google oauth providers" do
          expect(user).not_to be_valid
        end

        it "requires at least one Google oauth identity for internal users" do
          expect(user.identities.map { |i| i.identity_provider.strategy }).not_to include("google_oauth2")
          expect(user).not_to be_valid
        end
      end

      context "edge cases" do
        it "handles nil provider gracefully" do
          user.identities.build(identity_provider: nil, provider_user_id: "test_123")

          # Should not raise error
          expect { validator.validate(user) }.not_to raise_error
        end

        it "is case-sensitive for strategy matching" do
          wrong_case_provider = create(:identity_provider,
            strategy: "Google_OAuth2",  # Wrong case
            name: "Google Wrong Case",
            client_id: "test_id",
            client_secret: "test_secret")

          user.identities.create!(identity_provider: wrong_case_provider, provider_user_id: "test_123")

          validator.validate(user)
          expect(user.errors[:identities]).to include("must use Google authentication")
        end
      end
    end
  end

  describe "validator logic breakdown" do
    let(:user) { build(:user) }

    it "returns early if user is not internal" do
      expect(user.internal?).to be false
      result = validator.validate(user)
      expect(result).to be true
    end

    it "returns early if user has at least one google_oauth2 identity" do
      user.save
      user.create_organization_membership(organization: perceptive_org, role: :member)
      user.reload

      google_provider = IdentityProvider.find_by(strategy: "google_oauth2") ||
        create(:google_identity_provider)
      user.identities.create!(identity_provider: google_provider, provider_user_id: "google_123")

      expect(user.internal?).to be true
      expect(user.identities.any?).to be true
      expect(user.identities.none? { |i| i.identity_provider&.strategy == "google_oauth2" }).to be false

      result = validator.validate(user)
      expect(result).to be true
    end
  end
end
