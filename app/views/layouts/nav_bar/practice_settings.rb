class Views::Layouts::NavBar::PracticeSettings < Components::Base
  def view_template
    a(href: edit_practice_path(Current.practice), class: "btn btn-ghost btn-circle mt-2") do
      render PhlexIcons::Lucide::Settings.new
    end
  end
end
