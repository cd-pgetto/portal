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
  end

  def update
    authorize @practice
  end

  def select
    authorize @practice
    if @practice
      select_current_practice(@practice)
      redirect_to practice_path(@practice)
    else
      redirect_to home_path, alert: "Practice not found or you do not have access."
    end
  end

  private

  def set_practice
    @practice = Current.user.practices.find(params[:id])
  end
end
