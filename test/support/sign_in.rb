# Helpers for signing in during request (integration) tests.
module SignInHelper
  # Signs in via the session form (password auth). Used in integration tests.
  def sign_in_as(user, password)
    post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: password}
  end

  # Signs in as a system admin via password auth. Creates one if no user given.
  def sign_in_as_admin(user = nil)
    user ||= create_system_admin
    sign_in_as(user, USER_PASSWORD)
  end

  # Signs in via OmniAuth callback. Pass an explicit user.
  def sign_in_via_omniauth(user, provider: :google_oauth2, uid: "123456789")
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] =
      OmniAuth::AuthHash.new({
        provider: provider, uid: uid,
        extra: {id_info: {hd: user.organization.primary_email_domain}},
        info: {first_name: user.first_name, last_name: user.last_name, email: user.email_address}
      })
    post "/oauth/#{provider}/callback"
  end

  # Signs in by directly creating a session record. Used in view tests where
  # no HTTP request is available.
  def sign_in_directly(user)
    user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1").tap do |session|
      Current.session = session
    end
  end

  USER_PASSWORD = "The-quick-brown-fox-8-a-bird"
end
