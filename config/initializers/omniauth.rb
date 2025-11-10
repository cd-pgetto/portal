Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  # TODO: Use setup to initalize from DB-stored credentials
  provider :google_oauth2,
    Rails.application.credentials.dig(:omniauth, :google_oauth2, :client_id),
    Rails.application.credentials.dig(:omniauth, :google_oauth2, :client_secret)

  # provider :okta,
  #   setup: ->(env) { OmniAuthOktaProvider.setup(env) }
end

OmniAuth.configure do |config|
  config.logger = Rails.logger
  config.path_prefix = "/oauth"
end
