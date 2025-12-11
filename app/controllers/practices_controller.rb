class PracticesController < ApplicationController
  before_action :set_practice, only: [:show, :edit, :update, :select]
  authorize_resource

  def index
    @practices = Current.user.practices.distinct.order(:name)
  end

  def show
    render Views::Practices::Show.new(practice: @practice)
  end

  def edit
  end

  def update
  end

  def select
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
