class Views::Admin::Organizations::Index < Views::Base
  def initialize(organizations:)
    @organizations = organizations
  end

  def view_template
    content_for :title, "Organizations"

    div(class: "w-full") do
      div(class: "flex justify-between items-center mb-5") do
        h1(class: "font-bold text-3xl underline") { "Organizations" }
        a(href: new_admin_organization_path, class: "btn btn-primary") { "New organization" }
      end

      div(id: "organizations") do
        table(class: "table table-md") do
          thead do
            tr(class: "text-bold") do
              th { "Name" }
              th { "Subdomain" }
              th(class: "max-w-24 whitespace-normal") { "Allow Password Auth" }
              th { "Actions" }
            end
          end
          tbody do
            @organizations&.each do |organization|
              tr(class: "hover:bg-base-300") do
                td { a(href: admin_organization_path(organization), class: "text-primary font-bold text-lg") { organization.name } }
                td { organization.subdomain }
                td { organization.password_auth_allowed? ? "Yes" : "No" }
                td do
                  button_to(admin_organization_path(organization), method: :delete, class: "btn",
                    data: {turbo_confirm: "Are you sure?"}) {
                      render PhlexIcons::Lucide::Trash.new(class: "size-6 text-error")
                    }
                end
              end
            end
          end
        end
      end
    end
  end
end
