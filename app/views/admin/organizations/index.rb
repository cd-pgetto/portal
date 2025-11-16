class Views::Admin::Organizations::Index < Views::Base
  def initialize(organizations:)
    @organizations = organizations
  end

  def view_template
    content_for :title, "Organizations"

    div(class: "w-full") do
      div(class: "flex justify-between items-center mb-5") do
        h1(class: "font-semibold text-2xl") { "Organizations" }
        a(href: new_admin_organization_path, class: "btn btn-primary") { "New organization" }
      end

      div(id: "organizations", class: "bg-base-200 border border-base-content rounded-box p-4") do
        table(class: "table table-md text-center") do
          thead do
            tr(class: "font-bold border-b border-base-content") do
              th(class: "text-left") { "Name" }
              th { "Subdomain" }
              th(class: "whitespace-normal") { "Passwords?" }
              th(class: "whitespace-normal") { "Email Domains" }
              th(class: "whitespace-normal") { "Shared IdPs" }
              th(class: "whitespace-normal") { "Dedicated IdPs" }
              th(class: "border-l border-base-content") { "Actions" }
            end
          end
          tbody do
            @organizations&.each do |organization|
              tr(class: "hover:bg-base-300") do
                td(class: "text-left") { a(href: admin_organization_path(organization), class: "link link-primary") { organization.name } }
                td { organization.subdomain }
                td { organization.password_auth_allowed? ? "Yes" : "No" }
                td { organization.email_domains.count }
                td { organization.shared_identity_providers.count }
                td { organization.dedicated_identity_providers.count }
                td(class: "border-l border-base-content") do
                  # flex flex-col sm:flex-row gap-1 w-fit mx-auto
                  div(class: "w-full sm:w-auto flex flex-col sm:flex-row justify-center space-x-4 ") do
                    a(href: edit_admin_organization_path(organization), class: "btn") { render PhlexIcons::Lucide::Pencil.new }
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
end
