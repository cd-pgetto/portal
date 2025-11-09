class Views::Layouts::NavBar::NavBar < Components::Base
  def initialize(authenticated_user: nil)
    @authenticated_user = authenticated_user
  end

  def view_template
    nav(class: "navbar bg-base-100 h-12 border-b-2 border-primary") do
      div(class: "navbar-start") { render Views::Layouts::NavBar::HomeButton.new }
      div(class: "navbar-end") { render Views::Layouts::NavBar::UserMenu.new(authenticated_user: @authenticated_user) if @authenticated_user }
    end
  end
end
