class PracticesController < ApplicationController
  before_action :set_practice, only: [:show, :edit, :update, :select]

  def index
    authorize Practice
    @practices = policy_scope(Practice).distinct.order(:name)
  end

  def show
    authorize @practice
    render Views::Practices::Show.new(practice: @practice)
  end

  def edit
    authorize @practice
    render Views::Practices::Edit.new(practice: @practice)
  end

  def update
    authorize @practice
    if @practice.update(practice_params)
      redirect_to practice_path(@practice), notice: "Practice was successfully updated.", status: :see_other
    else
      flash.now.alert = "Practice could not be updated. Please correct the errors and try again."
      render Views::Practices::Edit.new(practice: @practice), status: :unprocessable_content
    end
  end

  def select
    authorize @practice
    select_current_practice(@practice)
    redirect_to practice_path(@practice)
  end

  private

  def set_practice
    @practice = Current.user.practices.find(params[:id])
  end

  def practice_params
    params.require(:practice).permit(:name)
  end
end
