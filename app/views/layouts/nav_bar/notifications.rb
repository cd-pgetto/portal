class Views::Layouts::NavBar::Notifications < Views::Base
  def view_template
    button(id: "notifications", class: "btn btn-ghost btn-circle mt-2") do
      div(class: "indicator") do
        div { render PhlexIcons::Lucide::Bell.new }
        span(class: "indicator-item badge badge-primary badge-xs")
      end
    end
  end
end
