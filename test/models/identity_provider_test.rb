require "test_helper"

describe IdentityProvider do
  describe ".available_strategies" do
    it "returns an array of strings" do
      strategies = IdentityProvider.available_strategies
      assert_kind_of Array, strategies
      assert strategies.all? { |s| s.is_a?(String) }
    end

    it "returns sorted results" do
      strategies = IdentityProvider.available_strategies
      assert_equal strategies.sort, strategies
    end

    it "excludes blank values" do
      assert IdentityProvider.available_strategies.all?(&:present?)
    end

    it "includes google_oauth2" do
      assert_includes IdentityProvider.available_strategies, "google_oauth2"
    end
  end
end

describe IdentityProvider::Shared do
  it "prevents two shared providers with the same strategy" do
    create(:identity_provider, strategy: "github")
    duplicate = build(:identity_provider, strategy: "github")
    refute duplicate.valid?
  end

  it "requires a strategy" do
    idp = build(:identity_provider, strategy: nil)
    refute idp.valid?
    assert idp.errors[:strategy].present?
  end

  it "requires a name" do
    idp = build(:identity_provider, name: nil)
    refute idp.valid?
    assert idp.errors[:name].present?
  end

  it "requires an icon_url" do
    idp = build(:identity_provider, icon_url: nil)
    refute idp.valid?
    assert idp.errors[:icon_url].present?
  end

  it "is shared and not dedicated" do
    idp = build(:identity_provider)
    assert idp.shared?
    refute idp.dedicated?
  end
end

describe IdentityProvider::Dedicated do
  it "is dedicated and not shared" do
    idp = build(:okta_identity_provider)
    assert idp.dedicated?
    refute idp.shared?
  end

  it "requires an organization" do
    idp = build(:okta_identity_provider, organization: nil)
    refute idp.valid?
    assert idp.errors[:organization].present?
  end

  it "requires a client_id" do
    idp = build(:okta_identity_provider, client_id: nil)
    refute idp.valid?
    assert idp.errors[:client_id].present?
  end

  it "requires a client_secret" do
    idp = build(:okta_identity_provider, client_secret: nil)
    refute idp.valid?
    assert idp.errors[:client_secret].present?
  end

  it "returns the class name for a known strategy" do
    assert_equal "IdentityProvider::Okta", IdentityProvider::Dedicated.class_for_strategy("okta")
  end

  it "returns nil for an unknown strategy" do
    assert_nil IdentityProvider::Dedicated.class_for_strategy("unknown")
  end

  it "includes okta in dedicated_strategies" do
    assert_includes IdentityProvider::Dedicated.dedicated_strategies, "okta"
  end
end

describe IdentityProvider::Okta do
  let(:okta_idp) { create(:okta_identity_provider) }
  let(:strategy) { Minitest::Mock.new }
  let(:strategy_options) { {client_options: {}} }

  it "is a kind of IdentityProvider" do
    assert_kind_of IdentityProvider, build(:okta_identity_provider)
  end

  it "requires an okta_domain" do
    idp = build(:okta_identity_provider, okta_domain: nil)
    refute idp.valid?
    assert idp.errors[:okta_domain].present?
  end

  describe ".setup" do
    def assert_strategy_configured(env, okta_idp)
      site = "https://#{okta_idp.okta_domain}.okta.com"
      options = {}

      strategy = Object.new
      strategy.define_singleton_method(:options) { options }
      options[:client_options] = {}

      env["omniauth.strategy"] = strategy
      IdentityProvider::Okta.setup(env)

      assert_equal okta_idp.client_id, options[:client_id]
      assert_equal okta_idp.client_secret, options[:client_secret]
      assert_equal site, options[:client_options][:site]
      assert_equal "#{site}/oauth2/default/v1/authorize", options[:client_options][:authorize_url]
      assert_equal "#{site}/oauth2/default/v1/token", options[:client_options][:token_url]
      assert_equal "#{site}/oauth2/default/v1/userinfo", options[:client_options][:user_info_url]
    end

    it "configures the strategy when identity_provider_id is in params" do
      env = {
        "omniauth.strategy" => nil,
        "omniauth.params" => {"identity_provider_id" => okta_idp.id}
      }
      assert_strategy_configured(env, okta_idp)
    end

    it "configures the strategy when found via request host" do
      organization = create(:organization, subdomain: "acme-okta-test")
      idp = create(:okta_identity_provider, organization: organization)
      env = {
        "omniauth.strategy" => nil,
        "omniauth.params" => {},
        "rack.input" => StringIO.new,
        "HTTP_HOST" => "acme-okta-test.example.com",
        "REQUEST_METHOD" => "GET",
        "QUERY_STRING" => ""
      }
      assert_strategy_configured(env, idp)
    end
  end
end
