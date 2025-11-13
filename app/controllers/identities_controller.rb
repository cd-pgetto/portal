class IdentitiesController < ApplicationController
  allow_unauthenticated_access
  skip_authorization_check

  # TODO: Review and clean up Claude-generated code
  #
  def create
    # Check if the provider is supported, reject otherwise
    identity_provider = IdentityProvider.find_by(strategy: params[:provider])

    return redirect_to sign_in_path, alert: "Authentication provider not supported." unless identity_provider
    return redirect_to sign_in_path, alert: "Authentication provider not allowed." unless organization.identity_provider_allowed?(identity_provider)
    return redirect_to sign_in_path, alert: "Email not allowed for #{organization.name}." unless organization.email_allowed?(user_email)

    provider_user_id = auth_params[:provider_user_id]
    oauth_identity = identity_provider.identities.find_by(provider_user_id: provider_user_id)
    if oauth_identity
      user = oauth_identity.user

    else
      # No existing identity, check if user exists by email
      # and create new user if not. Then build a new identity for the user.
      #
      # TODO: Check if the provider is allowed for this user (both new user and existing one w/o this identity)
      # based on their organization or subdomain.
      #
      ActiveRecord::Base.transaction do
        user = User.create_with(**user_params.merge(password: User.random_password))
          .find_or_create_by(email: user_email)
        user.oauth_identities.create_with(provider_user_id: provider_user_id)
          .find_or_create_by(provider: identity_provider)
        user.organization = organization if user.organization.nil? && !organization.is_a?(Organization::Null)
      end
    end

    start_new_session_for user
    redirect_to after_authentication_url
  end

  def failure
    redirect_to sign_in_path, alert: "Authentication failed."
  end

  private

  def auth_params
    {provider: auth_info[:provider], provider_user_id: auth_info[:uid]}
  end

  def user_params
    {
      first_name: auth_info.dig(:info, :first_name),
      last_name: auth_info.dig(:info, :last_name),
      # image_url: auth_info.dig(:info, :image),
      email: user_email
    }
  end

  def user_email
    auth_info.dig(:info, :email)
  end

  def auth_info
    request.env["omniauth.auth"]
  end

  def organization
    @organization ||= Organization.find_by_subdomain_or_email(request.subdomain, user_email)
  end
end
