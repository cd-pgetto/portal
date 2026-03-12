class OktaIdentityProvider < DedicatedIdentityProvider
  validates :okta_domain, presence: true

  def self.find_by_host(host)
    org = Organization.find_by(subdomain: host.split(".").first)
    idp = org&.dedicated_identity_provider
    idp.is_a?(OktaIdentityProvider) ? idp : nil
  end

  def self.setup(env)
    request = Rack::Request.new(env)
    identity_provider_id = env.fetch("omniauth.params", {}).merge(request.params)["identity_provider_id"]
    okta_idp = OktaIdentityProvider.find_by(id: identity_provider_id) || find_by_host(request.host)
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
