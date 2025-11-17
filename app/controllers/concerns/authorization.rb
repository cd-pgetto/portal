# CanCanCan authorization concern for controllers
# Ensures that authorization is checked for every action
# Handles AccessDenied exceptions by redirecting with an alert message
# Dynamically loads the appropriate Ability class based on the controller's resource
# to provide fine-grained access control

module Authorization
  extend ActiveSupport::Concern

  included do
    include CanCan::ControllerAdditions

    check_authorization

    rescue_from CanCan::AccessDenied do |_exception|
      respond_to do |format|
        format.html do
          redirect_to(Current.user || root_url, alert: "You are not authorized to access that page.")
        end
      end
    end
  end

  # load and instantiate per-controller ability class
  # def current_ability
  #   resource_class = self.class.name.gsub("Controller", "").singularize
  #   @current_ability ||= "#{resource_class}Ability".constantize.new(Current.user)
  # end

  def current_user = Current.user
end
