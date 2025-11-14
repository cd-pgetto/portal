class Views::Admin::Dashboards::Show < Views::Base
  def view_template
    content_for :title, "Admin Dashboard"

    div(class: "md:w-2/3 w-full") do
      div(class: "stats shadow") do
        div(class: "stat") do
          div(class: "stat-title") { "Organizations" }
          div(class: "stat-value") { a(href: admin_organizations_path) { Organization.count } }
        end
        div(class: "stat") do
          div(class: "stat-title") { "Users" }
          div(class: "stat-value") { User.count }
        end
        div(class: "stat") do
          div(class: "stat-title") { "Practices" }
          # div(class: "stat-value") { Practice.count }
        end
      end
    end
  end

  private
end
