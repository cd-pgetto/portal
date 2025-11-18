class Views::Layouts::DaisyNavBar < Views::Base
  def view_template
    # <nav class="navbar w-full bg-base-300">
    nav(class: "navbar w-full bg-base-300") do
      #   <label for="my-drawer-4" aria-label="open sidebar" class="btn btn-square btn-ghost">
      label(for: "my-drawer-4", aria: {label: "open sidebar"}, class: "btn btn-square btn-ghost") do
        # Sidebar toggle icon
        render PhlexIcons::Lucide::Menu.new(size: 24)
      end
      div(class: "px-4") { "Perceptive Portal (Phlex)" }
    end
  end
end
