# == Schema Information
#
# Table name: identity_providers
# Database name: primary
#
#  id              :uuid             not null, primary key
#  client_secret   :text             default("")
#  icon_url        :string           not null
#  name            :string           not null
#  okta_domain     :string
#  strategy        :string           not null
#  type            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  client_id       :text             default("")
#  organization_id :uuid
#
# Indexes
#
#  index_identity_providers_on_organization_id  (organization_id) UNIQUE WHERE (organization_id IS NOT NULL)
#  index_identity_providers_on_strategy         (strategy) UNIQUE WHERE (organization_id IS NULL)
#  index_identity_providers_on_type             (type)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require "rails_helper"

RSpec.describe OktaIdentityProvider, type: :model do
  subject { build(:okta_identity_provider) }

  it { is_expected.to be_a(IdentityProvider) }
  it { is_expected.to validate_presence_of(:okta_domain) }

  describe ".setup" do
    let(:okta_idp) { create(:okta_identity_provider) }
    let(:strategy) { instance_double("OmniAuth::Strategies::Okta", options: {client_options: {}}) }
    let(:env) { {"omniauth.strategy" => strategy} }

    shared_examples "configures the strategy" do
      it "sets client_id" do
        OktaIdentityProvider.setup(env)
        expect(strategy.options[:client_id]).to eq(okta_idp.client_id)
      end

      it "sets client_secret" do
        OktaIdentityProvider.setup(env)
        expect(strategy.options[:client_secret]).to eq(okta_idp.client_secret)
      end

      it "sets client_options from okta_domain" do
        OktaIdentityProvider.setup(env)
        site = "https://#{okta_idp.okta_domain}.okta.com"
        expect(strategy.options[:client_options][:site]).to eq(site)
        expect(strategy.options[:client_options][:authorize_url]).to eq("#{site}/oauth2/default/v1/authorize")
        expect(strategy.options[:client_options][:token_url]).to eq("#{site}/oauth2/default/v1/token")
        expect(strategy.options[:client_options][:user_info_url]).to eq("#{site}/oauth2/default/v1/userinfo")
      end
    end

    context "when identity_provider_id is present in params" do
      let(:env) { super().merge("omniauth.params" => {"identity_provider_id" => okta_idp.id}) }

      include_examples "configures the strategy"
    end

    context "when identity_provider_id is absent and provider is found via request host" do
      let(:organization) { create(:organization, subdomain: "acme") }
      let(:okta_idp) { create(:okta_identity_provider, organization: organization) }

      before do
        okta_idp # ensure created
        env["rack.input"] = StringIO.new
        env["HTTP_HOST"] = "acme.example.com"
        env["REQUEST_METHOD"] = "GET"
        env["QUERY_STRING"] = ""
      end

      include_examples "configures the strategy"
    end
  end
end
