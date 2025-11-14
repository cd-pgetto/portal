class Views::Admin::SideNavBar < Views::Base
  def view_template
    input(id: "nav-sidebar-drawer-1", type: "checkbox", class: "drawer-toggle")
    label(for: "nav-sidebar-drawer-1", aria: {label: "open sidebar"}, class: "float-left btn drawer-button lg:hidden") do
      render PhlexIcons::Lucide::Menu.new(size: 24)
    end

    div(class: "drawer-side h-[calc(100vh-8rem)] border-r-2 border-primary") do
      label(for: "nav-sidebar-drawer-1", aria: {label: "close sidebar"}, class: "drawer-overlay")
      ul(class: "menu bg-base-200 w-60 p-4") do
        li { a(href: admin_dashboard_path, class: "btn btn-light") { "Dashboard" } }
        li { a(href: admin_organizations_path, class: "btn btn-light") { "Organizations" } }
        li { a(href: admin_identity_providers_path, class: "btn btn-light") { "Identity Providers" } }
      end
    end
  end
end
