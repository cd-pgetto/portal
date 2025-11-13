class Views::Users::Step2 < Views::Base
  def initialize(user:, identity_providers:, password_auth_allowed:)
    @user = user
    @identity_providers = identity_providers
    @password_auth_allowed = password_auth_allowed
  end

  attr_reader :user, :identity_providers, :password_auth_allowed

  def view_template
    turbo_frame_tag("user_registration_form") do
      render Views::Users::Step2PasswordForm.new(user:) if password_auth_allowed
      span(class: "divider") { "OR" } if password_auth_allowed && identity_providers.any?
      render Views::Shared::IdentityProviderButtons.new(identity_providers:, action: "Sign Up")
    end
  end
end
