class Admin::DashboardsController < Admin::BaseController
  def show
    authorize :dashboard
    render Views::Admin::Dashboards::Show.new
  end
end
