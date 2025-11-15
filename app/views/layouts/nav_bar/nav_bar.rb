class Views::Layouts::NavBar::NavBar < Components::Base
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def view_template
    nav(class: "navbar bg-base-100 h-12 border-b-2 border-primary") do
      div(class: "navbar-start") { render Views::Layouts::NavBar::HomeButton.new }
      div(class: "navbar-end") { render Views::Layouts::NavBar::UserMenu.new(current_user: @current_user) }
    end
  end
end
