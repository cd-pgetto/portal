module Authorization
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    # Ensure authorization checks are performed in all non-production environments.
    after_action :verify_authorized unless Rails.env.production?

    rescue_from Pundit::NotAuthorizedError do |_exception|
      respond_to do |format|
        format.html do
          redirect_to(home_path, alert: "You are not authorized to access that page.")
        end
      end
    end
  end

  def current_user = Current.user
end
