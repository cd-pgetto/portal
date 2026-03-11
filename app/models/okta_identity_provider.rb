# == Schema Information
#
# Table name: identity_providers
# Database name: primary
#
#  id            :uuid             not null, primary key
#  availability  :enum             default("shared"), not null
#  client_secret :string           not null
#  icon_url      :string           not null
#  name          :string           not null
#  okta_domain   :string
#  strategy      :string           not null
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  client_id     :string           not null
#
# Indexes
#
#  index_identity_providers_on_strategy                (strategy) UNIQUE WHERE (availability = 'shared'::availability)
#  index_identity_providers_on_strategy_and_client_id  (strategy,client_id) UNIQUE
#  index_identity_providers_on_type                    (type)
#
class OktaIdentityProvider < IdentityProvider
  validates :okta_domain, presence: true

  def self.find_by_host(host)
    Organization.find_by(subdomain: host.split(".").first).dedicated_identity_providers.where(strategy: "okta")
  end

  def self.setup(env)
    request = Rack::Request.new(env)
    identity_provider_id = env.fetch("omniauth.params", {}).merge(request.params)["identity_provider_id"]
    okta_idp = OktaIdentityProvider.find_by(id: identity_provider_id) || find_by_host(request.host).first
    okta_idp&.setup(env["omniauth.strategy"])
  end

  def setup(strategy)
    strategy.options[:client_id] = client_id
    strategy.options[:client_secret] = client_secret
    strategy.options[:client_options][:site] = site_url
    strategy.options[:client_options][:token_url] = token_url
    strategy.options[:client_options][:authorize_url] = authorize_url
    strategy.options[:client_options][:user_info_url] = user_info_url
  end

  def site_url = "https://#{okta_domain}.okta.com"
  def oauth_url = "#{site_url}/oauth2/default/v1"
  def authorize_url = "#{oauth_url}/authorize"
  def token_url = "#{oauth_url}/token"
  def user_info_url = "#{oauth_url}/userinfo"
end
