class Views::Layouts::NavBar::UserMenu < Components::Base
  include Phlex::Rails::Helpers::ControllerName

  def initialize(current_user:)
    @current_user = current_user
  end

  def view_template
    on_sign_up = controller_name == "users"

    div(class: "flex-none") do
      ul(class: "menu menu-horizontal px-1") do
        if @current_user
          li(id: "notifications") { render Views::Layouts::NavBar::Notifications.new }
          li(id: "user-details-menu") { render Views::Layouts::NavBar::UserDetailsMenu.new(@current_user) }
        else
          li(class: "mx-2") { a(href: new_user_path, data: {turbo_prefetch: "false"}, disabled: on_sign_up, class: "btn btn-accent") { "Sign Up" } }
          li(class: "mx-2") { a(href: new_session_path, data: {turbo_prefetch: "false"}, disabled: !on_sign_up, class: "btn btn-accent") { "Sign In" } }
        end
      end
    end
  end
end
