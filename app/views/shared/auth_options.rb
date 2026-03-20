class Views::Shared::AuthOptions < Views::Base
  def initialize(user:, identity_providers:, password_auth_allowed:, action: "Sign Up")
    @user = user
    @identity_providers = identity_providers
    @password_auth_allowed = password_auth_allowed
    @action = action
  end

  def view_template
    render Views::Users::Step2PasswordForm.new(user: @user) if @password_auth_allowed
    span(class: "divider") { "OR" } if @password_auth_allowed && @identity_providers.any?
    render Views::Shared::IdentityProviderButtons.new(identity_providers: @identity_providers, action: @action)
  end
end
