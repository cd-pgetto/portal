class Views::Users::Step2 < Views::Base
  def initialize(user:, identity_providers:, password_auth_allowed:)
    @user = user
    @identity_providers = identity_providers
    @password_auth_allowed = password_auth_allowed
  end

  attr_reader :user, :identity_providers, :password_auth_allowed

  def view_template
    turbo_frame_tag("user_registration_form") do
      render Views::Shared::AuthOptions.new(user:, identity_providers:, password_auth_allowed:)
    end
  end
end
