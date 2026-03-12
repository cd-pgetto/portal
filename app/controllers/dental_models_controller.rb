class DentalModelsController < ApplicationController
  before_action :set_dental_model, only: [:show]

  def show
    authorize @dental_model
  end

  private

  def set_dental_model
    @dental_model = DentalModel.find(params[:id])
  end
end
