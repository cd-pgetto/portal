class HomeController < ApplicationController
  skip_authorization_check

  def show
    return redirect_to admin_dashboard_path if Current.user&.system_admin?
    return redirect_to Current.practice if Current.practice.present?
    redirect_to practice_path(Current.user.practices.first) if Current.user&.practices&.any?
  end
end
