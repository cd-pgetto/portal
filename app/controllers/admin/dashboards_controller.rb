class Admin::DashboardsController < Admin::BaseController
  def show
    authorize! :read, :dashboard
    render Views::Admin::Dashboards::Show.new
  end
end
