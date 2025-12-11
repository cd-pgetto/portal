class Views::Admin::Users::Index < Views::Base
  def initialize(users:)
    @users = users
  end

  def view_template
    render Components::Admin::Index.new(records: @users) do |table|
      table.header do
        th { "Organization" }
        th { "Name" }
        th { "Email" }
        th(class: "text-center") { "Locked?" }
        th(class: "text-center") { "Practices" }
        th(class: "text-center") { "Identities" }
        th(class: "text-center border-l border-base-content") { "Actions" }
      end

      table.row do |user|
        td { a(href: admin_organization_path(user.organization), class: "link link-primary") { user.organization.name } if user.organization }
        td { a(href: admin_user_path(user), class: "link link-primary") { user.full_name } }
        td { user.email_address }
        td(class: "text-center") { user.locked? ? "Yes" : "No" }
        td(class: "text-center") { user.practices.distinct.count }
        td(class: "text-center") { user.identities_count }
        td(class: "border-l border-base-content") { render Components::Admin::Index::Actions.new(record: user) }
      end
    end
  end
end
