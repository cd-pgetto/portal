class Views::Layouts::NavBar::UserMenu < Components::Base
  include Phlex::Rails::Helpers::ActionName
  include Phlex::Rails::Helpers::ControllerName

  def initialize(authenticated_user:)
    @authenticated_user = authenticated_user
  end

  def view_template
    on_sign_up = controller_name == "users" && (action_name == "new" || action_name == "create")

    div(class: "flex-none") do
      ul(class: "menu menu-horizontal px-1") do
        if @authenticated_user
          li { render Views::Layouts::NavBar::Notifications.new }
          li { render Views::Layouts::NavBar::UserDetailsMenu.new(@authenticated_user) }
        else
          li(class: "mx-2") { a(href: sign_up_path, data: {turbo_prefetch: "false"}, disabled: on_sign_up, class: "btn btn-accent") { "Sign Up" } }
          li(class: "mx-2") { a(href: new_session_path, data: {turbo_prefetch: "false"}, disabled: !on_sign_up, class: "btn btn-accent") { "Sign In" } }
        end
      end
    end
  end
end
