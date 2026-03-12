class Admin::OrganizationsController < Admin::BaseController
  before_action :set_organization, only: %i[show edit update destroy]

  # GET /admin/organizations or /admin/organizations.json
  def index
    authorize Organization
    render Views::Admin::Organizations::Index.new(organizations: policy_scope(Organization).includes(:dedicated_identity_provider).order(:name))
  end

  # GET /admin/organizations/1 or /admin/organizations/1.json
  def show
    authorize @organization
    render Views::Admin::Organizations::Show.new(organization: @organization)
  end

  # GET /admin/organizations/new
  def new
    @organization = Organization.new
    authorize @organization
    render Views::Admin::Organizations::New.new(organization: @organization)
  end

  # POST /admin/organizations or /admin/organizations.json
  def create
    @organization = Organization.new(organization_params)
    authorize @organization
    respond_to do |format|
      if @organization.save
        format.html { redirect_to admin_organization_path(@organization), notice: "Organization was successfully created." }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render Views::Admin::Organizations::New.new(organization: @organization), status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # GET /admin/organizations/1/edit
  def edit
    authorize @organization
    render Views::Admin::Organizations::Edit.new(organization: @organization)
  end

  # PATCH/PUT /admin/organizations/1 or /admin/organizations/1.json
  def update
    authorize @organization
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to admin_organization_path(@organization), notice: "Organization was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render Views::Admin::Organizations::Edit.new(organization: @organization), status: :unprocessable_content }
        format.json { render json: @organization.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /admin/organizations/1 or /admin/organizations/1.json
  def destroy
    authorize @organization
    @organization.destroy!

    respond_to do |format|
      format.html { redirect_to admin_organizations_path, notice: "Organization was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_organization
    @organization = Organization.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def organization_params
    permitted = params.require(:organization).permit(
      :name,
      :subdomain,
      :password_auth_allowed,
      shared_identity_provider_ids: [],
      practices_attributes: [:id, :name, :_destroy],
      email_domains_attributes: [:id, :domain_name, :_destroy],
      dedicated_identity_provider_attributes: [:id, :_destroy, :name, :strategy,
        :icon_url, :client_id, :client_secret, :okta_domain]
    )
    idp_attrs = permitted[:dedicated_identity_provider_attributes]
    if idp_attrs.present? && idp_attrs.fetch(:id, nil).blank?
      idp_attrs[:type] = DedicatedIdentityProvider.class_for_strategy(idp_attrs[:strategy])
    end
    permitted
  end
end
