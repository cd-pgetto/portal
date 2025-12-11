class Admin::PracticesController < Admin::BaseController
  before_action :set_practice, only: %i[edit update destroy]

  authorize_resource

  # GET /practices or /practices.json
  def index
    render Views::Admin::Practices::Index.new(practices: Practice.includes([:organization]).order(:name).all)
  end

  # GET /practices/1 or /practices/1.json
  def show
    @practice = Practice.includes([{members: :user}]).find(params.expect(:id))
  end

  # GET /practices/new
  def new
    @practice = Practice.new
  end

  # POST /practices or /practices.json
  def create
    @practice = Practice.new(practice_params)
    respond_to do |format|
      if @practice.save
        format.html { redirect_to [:admin, @practice], notice: "Practice was successfully created." }
        format.json { render :show, status: :created, location: @practice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /practices/1/edit
  def edit
  end

  # PATCH/PUT /practices/1 or /practices/1.json
  def update
    respond_to do |format|
      if @practice.update(practice_params)
        format.html { redirect_to [:admin, @practice], notice: "Practice was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @practice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @practice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /practices/1 or /practices/1.json
  def destroy
    @practice.destroy!

    respond_to do |format|
      format.html { redirect_to admin_practices_path, notice: "Practice was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_practice
    @practice = Practice.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def practice_params
    params.require(:practice).permit(:name, :organization_id)
  end
end
