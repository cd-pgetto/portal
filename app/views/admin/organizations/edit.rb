class Views::Admin::Organizations::Edit < Views::Base
  def initialize(organization:)
    @organization = organization
  end

  def view_template
    content_for :title, "Edit organization"

    div(class: "w-full") do
      render Views::Admin::Organizations::Form.new(organization: @organization)

      div(class: "md:w-md flex justify-between") do
        a(href: admin_organization_path(@organization), class: "btn") { "Cancel" }
        a(href: admin_organizations_path, class: "btn") { render PhlexIcons::Lucide::List.new }
      end
    end
  end
end
