class SessionsController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]
  skip_authorization_check
  before_action :redirect_signed_in_user, only: [:new, :create]

  def new
    render Views::Sessions::New.new(email_address: nil, identity_providers:, password_auth_allowed:)
  end

  NUM_SIGN_IN_STEPS = 2

  def create
    if params[:sign_in_step].to_i < NUM_SIGN_IN_STEPS
      render Views::Sessions::New.new(email_address: params[:email_address], identity_providers:, password_auth_allowed:)

    elsif (authenticated_user = User.authenticate_by(session_params))
      start_new_session_for authenticated_user
      respond_to do |format|
        format.html { redirect_to after_authentication_url }
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, after_authentication_url) }
      end

    else
      flash.now.alert = "Sign in failed. Please try another email address or password."
      render Views::Sessions::New.new(email_address: params[:email_address], identity_providers:, password_auth_allowed:), status: :unprocessable_content
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def session_params
    params.permit(:email_address, :password)
  end

  def identity_providers
    @identity_providers ||= organization.identity_providers
  end

  def password_auth_allowed
    @password_auth_allowed ||= organization.password_auth_allowed?
  end

  def organization
    @organization ||= Organization.find_by_subdomain_or_email(request.subdomain, params[:email])
  end

  # def too_many_failed_attempts
  #   alert_message = "Too many failed attempts. Try again later."
  #   respond_to do |format|
  #     format.html { redirect_to new_session_url, alert: alert_message }
  #     format.turbo_stream do
  #       flash.now[:alert] = alert_message
  #       render turbo_stream: turbo_stream.replace("user_sign_in_form", Views::Sessions::Step2.new(email_address: params[:email_address], identity_providers:, password_auth_allowed:))
  #     end
  #   end
  # end
end
