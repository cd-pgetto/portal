class Views::Layouts::NavBar::HomeButton < Components::Base
  def view_template
    a(href: root_path, class: "btn btn-ghost text-xl") do
      img(src: asset_path("perceptive-logo-white.png"), class: "theme-dark h-8")
      img(src: asset_path("perceptive-logo-dark.png"), class: "theme-light h-8")
    end
  end
end
