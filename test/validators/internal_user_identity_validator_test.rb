require "test_helper"

class InternalUserIdentityValidatorTest < ActiveSupport::TestCase
  let(:validator) { InternalUserIdentityValidator.new }
  let(:perceptive_org) { create(:perceptive) }

  describe "#validate" do
    describe "when user is not internal" do
      let(:user) { build(:another_user) }

      it "does not add errors for non-internal users" do
        validator.validate(user)
        assert_empty user.errors[:identities]
      end

      it "allows non-internal users without any oauth identities" do
        user.save
        assert user.valid?
        assert_empty user.identities
      end

      it "allows non-internal users with non-Google oauth identities" do
        user.save
        non_google_provider = create(:identity_provider, strategy: "github")
        user.identities.create(identity_provider: non_google_provider, provider_user_id: "github_123")
        validator.validate(user)
        assert_empty user.errors[:identities]
      end
    end

    describe "when user is internal" do
      let(:user) { build(:another_user) }

      before do
        user.save
        user.create_organization_membership(organization: perceptive_org, role: :member)
        user.reload
      end

      describe "without any oauth identities" do
        it "adds errors" do
          validator.validate(user)
          assert_not_empty user.errors[:identities]
        end

        it "does not allow internal users to exist without oauth identities" do
          assert_empty user.identities
          assert_not user.valid?
        end
      end

      describe "with Google OAuth identity" do
        before do
          google_provider = IdentityProvider.find_by(strategy: "google_oauth2") || create(:google_identity_provider)
          user.identities.create!(identity_provider: google_provider, provider_user_id: "google_123")
        end

        it "does not add errors" do
          validator.validate(user)
          assert_empty user.errors[:identities]
        end

        it "is valid with google_oauth2 strategy" do
          assert user.valid?
        end

        it "allows the user to have the correct oauth identity" do
          assert_equal 1, user.identities_count
          assert_equal "google_oauth2", user.identities.first.identity_provider.strategy
        end
      end

      describe "with non-Google OAuth identity" do
        let(:github_provider) do
          create(:identity_provider, strategy: "github", name: "GitHub",
            client_id: "github_client_id", client_secret: "github_secret")
        end

        before { user.identities.create!(identity_provider: github_provider, provider_user_id: "github_123") }

        it "adds an error to identities" do
          validator.validate(user)
          assert_includes user.errors[:identities], "must use Google authentication"
        end

        it "is invalid when using non-Google oauth provider" do
          assert_not user.valid?
          assert_includes user.errors.full_messages, "Identities must use Google authentication"
        end

        it "identifies the oauth identity has the wrong strategy" do
          assert_equal "github", user.identities.first.identity_provider.strategy
          assert_not_equal "google_oauth2", user.identities.first.identity_provider.strategy
        end
      end

      describe "with multiple OAuth identities including one non-Google" do
        let(:google_provider) { IdentityProvider.find_by(strategy: "google_oauth2") || create(:google_identity_provider) }
        let(:azure_provider) do
          create(:identity_provider, strategy: "azure_oauth2", name: "Azure AD",
            client_id: "azure_client_id", client_secret: "azure_secret")
        end

        before do
          google_provider
          azure_provider
          user.identities.create!(identity_provider: google_provider, provider_user_id: "google_123")
          user.identities.create!(identity_provider: azure_provider, provider_user_id: "azure_456")
        end

        it "is valid when at least one identity is Google" do
          validator.validate(user)
          assert_empty user.errors[:identities]
        end

        it "allows internal users with Google plus other oauth identities" do
          assert user.valid?
          assert_equal 2, user.identities_count
        end
      end

      describe "with only non-Google OAuth identities" do
        let(:facebook_provider) do
          create(:identity_provider, strategy: "facebook", name: "Facebook",
            client_id: "fb_client_id", client_secret: "fb_secret")
        end
        let(:twitter_provider) do
          create(:identity_provider, strategy: "twitter", name: "Twitter",
            client_id: "tw_client_id", client_secret: "tw_secret")
        end

        before do
          facebook_provider
          twitter_provider
          user.identities.create!(identity_provider: facebook_provider, provider_user_id: "fb_123")
          user.identities.create!(identity_provider: twitter_provider, provider_user_id: "tw_456")
        end

        it "adds an error when none of the identities are Google" do
          validator.validate(user)
          assert_includes user.errors[:identities], "must use Google authentication"
        end

        it "is invalid with multiple non-Google oauth providers" do
          assert_not user.valid?
        end

        it "requires at least one Google oauth identity for internal users" do
          strategies = user.identities.map { |i| i.identity_provider.strategy }
          assert_not_includes strategies, "google_oauth2"
          assert_not user.valid?
        end
      end

      describe "edge cases" do
        it "handles nil provider gracefully" do
          user.identities.build(identity_provider: nil, provider_user_id: "test_123")
          assert_silent { validator.validate(user) }
        end

        it "is case-sensitive for strategy matching" do
          wrong_case_provider = create(:identity_provider,
            strategy: "Google_OAuth2",
            name: "Google Wrong Case",
            client_id: "test_id",
            client_secret: "test_secret")
          user.identities.create!(identity_provider: wrong_case_provider, provider_user_id: "test_123")
          validator.validate(user)
          assert_includes user.errors[:identities], "must use Google authentication"
        end
      end
    end
  end

  describe "validator logic breakdown" do
    let(:user) { build(:another_user) }

    it "returns early if user is not internal" do
      assert_not user.internal?
      result = validator.validate(user)
      assert result
    end

    it "returns early if user has at least one google_oauth2 identity" do
      user.save
      user.create_organization_membership(organization: perceptive_org, role: :member)
      user.reload

      google_provider = IdentityProvider.find_by(strategy: "google_oauth2") || create(:google_identity_provider)
      user.identities.create!(identity_provider: google_provider, provider_user_id: "google_123")

      assert user.internal?
      assert user.identities.any?
      assert_not user.identities.none? { |i| i.identity_provider&.strategy == "google_oauth2" }

      result = validator.validate(user)
      assert result
    end
  end
end
