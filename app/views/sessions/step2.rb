class Views::Sessions::Step2 < Views::Base
  def initialize(email_address:, password_auth_allowed:, identity_providers:)
    @email_address = email_address
    @password_auth_allowed = password_auth_allowed
    @identity_providers = identity_providers
  end

  attr_reader :email_address, :identity_providers, :password_auth_allowed

  def view_template
    turbo_frame_tag("user_sign_in_form") do
      render Views::Sessions::Step2PasswordForm.new(email_address:) if password_auth_allowed
      span(class: "divider") { "OR" } if password_auth_allowed && identity_providers.any?
      render Views::Shared::IdentityProviderButtons.new(identity_providers:)
    end
  end
end
