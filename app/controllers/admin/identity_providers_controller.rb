class Admin::IdentityProvidersController < ApplicationController
  before_action :set_identity_provider, only: %i[show edit update destroy]

  # GET /identity_providers or /identity_providers.json
  def index
    authorize! :read, IdentityProvider
    render Views::Admin::IdentityProviders::Index.new(identity_providers: IdentityProvider.all.order(:name))
  end

  # GET /identity_providers/1 or /identity_providers/1.json
  def show
    authorize! :read, IdentityProvider
    render Views::Admin::IdentityProviders::Show.new(identity_provider: @identity_provider)
  end

  # GET /identity_providers/new
  def new
    authorize! :create, IdentityProvider
    @identity_provider = IdentityProvider.new
    render Views::Admin::IdentityProviders::New.new(identity_provider: @identity_provider)
  end

  # POST /identity_providers or /identity_providers.json
  def create
    authorize! :create, IdentityProvider
    @identity_provider = IdentityProvider.new(identity_provider_params)

    respond_to do |format|
      if @identity_provider.save
        format.html { redirect_to admin_identity_provider_path(@identity_provider), notice: "Identity provider was successfully created." }
        format.json { render :show, status: :created, location: @identity_provider }
      else
        format.html { render Views::Admin::IdentityProviders::New.new(identity_provider: @identity_provider), status: :unprocessable_entity }
        format.json { render json: @identity_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /identity_providers/1/edit
  def edit
    authorize! :update, IdentityProvider
    render Views::Admin::IdentityProviders::Edit.new(identity_provider: @identity_provider)
  end

  # PATCH/PUT /identity_providers/1 or /identity_providers/1.json
  def update
    authorize! :update, IdentityProvider
    respond_to do |format|
      if @identity_provider.update(identity_provider_params)
        format.html { redirect_to admin_identity_provider_path(@identity_provider), notice: "Identity provider was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @identity_provider }
      else
        format.html { render Views::Admin::IdentityProviders::Edit.new(identity_provider: @identity_provider), status: :unprocessable_entity }
        format.json { render json: @identity_provider.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identity_providers/1 or /identity_providers/1.json
  def destroy
    authorize! :destroy, IdentityProvider
    @identity_provider.destroy!

    respond_to do |format|
      format.html { redirect_to admin_identity_providers_path, notice: "Identity provider was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_identity_provider
    @identity_provider = IdentityProvider.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def identity_provider_params
    params.expect(identity_provider: [:name, :strategy, :availability, :icon_url, :client_id, :client_secret])
  end
end
