class Views::Layouts::NavBar::NavBar < Components::Base
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def view_template
    nav(class: "navbar bg-base-100 h-12 border-b-2 border-primary z-10") do
      div(class: "navbar-start") do
        render Views::Layouts::NavBar::HomeButton.new
        div(class: "ml-2 navbar-item") { Current.user&.organization&.name }
        render_practice_selection_list
      end

      div(class: "navbar-end") {
        render Views::Layouts::NavBar::UserMenu.new(current_user: @current_user)
      }
    end
  end

  def render_practice_selection_list
    if Current.user&.practices&.any?
      details(class: "dropdown") do
        summary(class: "btn m-1") {
          Current.practice&.name || ("Select Practice" if Current.user&.practices&.any?)
        }

        ul(class: "dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52") do
          Current.user&.practices&.distinct&.each do |practice|
            li { button_to practice.name, select_practice_path(practice), method: :post }
          end
        end
      end
    end
  end
end
