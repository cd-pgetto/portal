class Views::Admin::Organizations::New < Views::Base
  def initialize(organization:)
    @organization = organization
  end

  def view_template
    content_for :title, "New organization"

    div(class: "w-full") do
      h1(class: "font-bold text-2xl mb-2") { "New organization" }

      render Views::Admin::Organizations::Form.new(organization: @organization)

      a(href: admin_organizations_path, class: "btn") { "Cancel" }
    end
  end
end
