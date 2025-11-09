class Components::PerceptiveLockupThemed < Components::Base
  def view_template
    div(class: "text-center border-b-2 p-10") do
      img(src: asset_path("perceptive-lockup-white.png"), class: "theme-dark h-12")
      img(src: asset_path("perceptive-lockup-dark.png"), class: "theme-light h-12")
    end
  end
end
