class Graphical::DentalModelsController < ApplicationController
  layout "graphical"

  def show
    dental_model = authorize DentalModel.find(params[:id])
    render Views::Graphical::DentalModels::Show.new(dental_model: dental_model)
  end

  private

  def set_dental_model
    @dental_model = DentalModel.find(params[:id])
  end
end
