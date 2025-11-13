class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  skip_authorization_check only: %i[new create]
  before_action :redirect_signed_in_user, only: %i[new create]

  before_action :set_user, only: %i[show edit update]

  NUMBER_OF_STEPS = 2

  def show
    authorize! :read, @user
    render Views::Users::Show.new(user: @user)
  end

  def new
    user = User.new(registration_step: 1)
    render Views::Users::New.new(user:, identity_providers:, password_auth_allowed:)
  end

  def create
    user = User.new({first_name: "", last_name: "", password: ""}.merge(user_params))
    if !user.valid?
      flash.now.alert = "Please correct the errors and try again."
      render Views::Users::New.new(user:, identity_providers:, password_auth_allowed:), status: :unprocessable_content

    elsif user.registration_step.to_i < User::NUM_REGISTRATION_STEPS
      user.next_registration_step
      render Views::Users::New.new(user:, identity_providers:, password_auth_allowed:)

    else
      user.save!
      start_new_session_for(user)
      redirect_to home_url, notice: "Welcome to Perceptive."
    end
  end

  def edit
    authorize! :edit, @user
    render Views::Users::Edit.new(user: @user)
  end

  def update
    authorize! :update, @user
    if @user.update(user_params)
      redirect_to @user, notice: "Your account was successfully updated.", status: :see_other
    else
      flash.now.alert = "Your account could not be updated. Please correct the errors and try again."
      render Views::Users::Edit.new(user: @user), status: :unprocessable_content
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :password, :registration_step)
  end

  def identity_providers
    @identity_providers ||= organization.identity_providers
  end

  def password_auth_allowed
    @password_auth_allowed ||= organization.password_auth_allowed?
  end

  def password_auth_allowed?
    password_auth_allowed ? true : false
  end

  def organization
    @organization ||= Organization.find_by_subdomain_or_email(request.subdomain, params.dig(:user, :email_address))
  end
end
