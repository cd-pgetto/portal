class Admin::BaseController < ApplicationController
  before_action :require_admin

  layout "admin"

  private

  def require_admin
    unless Current.user&.system_admin?
      redirect_to root_path, alert: "You are not authorized to access this section."
    end
  end
end
