class Graphical::DentalModelsController < ApplicationController
  before_action :set_dental_model, only: [:show]
  authorize_resource

  layout "graphical"

  def show
    dental_model = DentalModel.find(params[:id])
    render Views::Graphical::DentalModels::Show.new(dental_model: dental_model)
  end

  private

  def set_dental_model
    @dental_model = DentalModel.find(params[:id])
  end
end
