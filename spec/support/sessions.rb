module Request
  def sign_in_as(user, password)
    post session_path, params: {sign_in_step: 2, email_address: user.email_address, password: password}
  end

  def sign_in_as_admin(user = create_system_admin, provider = :google_oauth2, uid = "123456789")
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[provider] =
      OmniAuth::AuthHash.new({
        provider: provider, uid: uid, extra: {id_info: {hd: user.organization.primary_email_domain}},
        info: {first_name: user.first_name, last_name: user.last_name, email_address: user.email_address}
      })

    post "/oauth/#{provider}/callback"
  end
end

module View
  def sign_in_as(user, _password = nil)
    user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1").tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = {value: session.id, httponly: true, same_site: :lax}
    end
    # session[:auth_token] = user.auth_token
    # session[:expires_at] = 1.hour.from_now
  end

  def sign_out
    session[:auth_token] = nil
    session[:expires_at] = 1.hour.ago
  end

  def expire_session
    session[:expires_at] = 1.hour.ago
  end
end

module System
  def sign_in_as(user, password)
    visit new_session_path
    fill_in "Email address", with: user.email
    click_button "Next"

    fill_in "Password", with: password
    click_button "Sign In"
  end

  # def login_as_admin(user = User.new(first_name: "Admin", last_name: "Perceptive", email_address: "admin@#{User::PRIMARY_INTERNAL_DOMAIN}"),
  #   provider = :google_oauth2, uid = "123456789")
  #   OmniAuth.config.test_mode = true
  #   OmniAuth.config.mock_auth[provider] =
  #     OmniAuth::AuthHash.new({provider: provider, uid: uid, extra: {id_info: {hd: "#{User::PRIMARY_INTERNAL_DOMAIN}"}},
  #                              info: {first_name: user.first_name, last_name: user.last_name, email_address: user.email_address}})

  #   visit login_path
  #   click_button "Sign in with Google"
  # end
end

RSpec.configure do |config|
  config.include Request, type: :request
  config.include View, type: :view
  config.include System, type: :system
end
