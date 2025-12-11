class Admin::OrganizationsController < Admin::BaseController
  before_action :set_organization, only: %i[show edit update destroy]

  authorize_resource

  # GET /admin/organizations or /admin/organizations.json
  def index
    render Views::Admin::Organizations::Index.new(organizations: Organization.order(:name).all)
  end

  # GET /admin/organizations/1 or /admin/organizations/1.json
  def show
    render Views::Admin::Organizations::Show.new(organization: @organization)
  end

  # GET /admin/organizations/new
  def new
    render Views::Admin::Organizations::New.new(organization: Organization.new)
  end

  # POST /admin/organizations or /admin/organizations.json
  def create
    @organization = Organization.new(organization_params)
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
    render Views::Admin::Organizations::Edit.new(organization: @organization)
  end

  # PATCH/PUT /admin/organizations/1 or /admin/organizations/1.json
  def update
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
    params.require(:organization).permit(
      :name,
      :subdomain,
      :password_auth_allowed,
      shared_identity_provider_ids: [],
      practices_attributes: [:id, :name, :_destroy],
      email_domains_attributes: [:id, :domain_name, :_destroy],
      credentials_attributes: [:id, :_destroy, :identity_provider_id,
        identity_provider_attributes: [:id, :_destroy, :name, :strategy, :icon_url,
          :client_id, :client_secret, :availability]]
    )
  end
end
