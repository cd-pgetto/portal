class HomeController < ApplicationController
  skip_authorization_check

  def show
    redirect_to admin_dashboard_path if Current.user&.system_admin?
  end
end
