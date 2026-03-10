class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy]

  # GET /patients or /patients.json
  def index
    authorize Patient
    @patients = policy_scope(Patient).where(practice: Current.practice).includes([:dental_models])
  end

  # GET /patients/1 or /patients/1.json
  def show
    authorize @patient
  end

  # GET /patients/new
  def new
    @patient = Patient.new(practice_id: Current.practice&.id)
    authorize @patient
  end

  # GET /patients/1/edit
  def edit
    authorize @patient
  end

  # POST /patients or /patients.json
  def create
    @patient = Patient.new(patient_params)
    authorize @patient

    respond_to do |format|
      if @patient.save
        format.html { redirect_to @patient, notice: "Patient was successfully created." }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @patient.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /patients/1 or /patients/1.json
  def update
    authorize @patient

    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to @patient, notice: "Patient was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @patient.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /patients/1 or /patients/1.json
  def destroy
    authorize @patient
    @patient.destroy!

    respond_to do |format|
      format.html { redirect_to patients_path, notice: "Patient was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_patient
    @patient = Current.practice.patients.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def patient_params
    params.fetch(:patient, {})
  end
end
