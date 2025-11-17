class Views::Admin::Organizations::Show < Views::Base
  def initialize(organization:)
    @organization = organization
  end

  def view_template
    content_for :title, "Organization: #{@organization.name}"

    div(class: "w-full") do
      div(class: "items-center pb-5 sm:pb-0") do
        # Organization details
        render Views::Admin::Organizations::Organization.new(organization: @organization)

        # Index, edit and destroy links/buttons
        div(class: "w-full mt-4 sm:w-auto flex flex-col sm:flex-row space-x-4 space-y-2") do
          a(href: admin_organizations_path, class: "btn") { render PhlexIcons::Lucide::List.new }
          a(href: edit_admin_organization_path(@organization), class: "btn") { render PhlexIcons::Lucide::Pencil.new }
          button_to(admin_organization_path(@organization), method: :delete, class: "btn",
            data: {turbo_confirm: "Are you sure?"}) {
              render PhlexIcons::Lucide::Trash.new(class: "size-6 text-error")
            }
        end
      end
    end
  end
end
