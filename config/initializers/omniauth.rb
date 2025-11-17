Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.development?

  # TODO: Use setup to initalize from DB-stored credentials

  # provider :apple,
  #   Rails.application.credentials.dig(:omniauth, :apple, :client_id), "",
  #   {
  #     scope: "email name",
  #     team_id: Rails.application.credentials.dig(:omniauth, :apple, :team_id),
  #     key_id: Rails.application.credentials.dig(:omniauth, :apple, :key_id),
  #     pem: Rails.application.credentials.dig(:omniauth, :apple, :private_key)
  #   }

  # provider :auth0,
  #   Rails.application.credentials.dig(:omniauth, :auth0, :client_id),
  #   Rails.application.credentials.dig(:omniauth, :auth0, :client_secret),
  #   Rails.application.credentials.dig(:omniauth, :auth0, :domain)

  provider :google_oauth2,
    Rails.application.credentials.dig(:omniauth, :google_oauth2, :client_id),
    Rails.application.credentials.dig(:omniauth, :google_oauth2, :client_secret)

  # provider :microsoft_office365,
  #   Rails.application.credentials.dig(:omniauth, :microsoft_office365, :client_id),
  #   Rails.application.credentials.dig(:omniauth, :microsoft_office365, :client_secret)

  # provider :okta,
  #   Rails.application.credentials.dig(:omniauth, :okta, :client_id),
  #   Rails.application.credentials.dig(:omniauth, :okta, :client_secret)
  # provider :okta,
  #   setup: ->(env) { OmniAuthOktaProvider.setup(env) }
end

OmniAuth.configure do |config|
  config.logger = Rails.logger
  config.path_prefix = "/oauth"
end
