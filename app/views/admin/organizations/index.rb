class Views::Admin::Organizations::Index < Views::Base
  def initialize(organizations:)
    @organizations = organizations
  end

  def view_template
    render Components::Admin::Index.new(records: @organizations) do |table|
      table.header do
        th { "Name" }
        th { "Subdomain" }
        th(class: "text-center") { "Practices" }
        th(class: "text-center") { "Passwords?" }
        th(class: "text-center") { "Email Domains" }
        th(class: "text-center") { "Shared IdPs" }
        th(class: "text-center") { "Dedicated IdPs" }
        th(class: "text-center border-l border-base-content") { "Actions" }
      end

      table.row do |organization|
        td { a(href: admin_organization_path(organization), class: "link link-primary") { organization.name } }
        td { organization.subdomain }
        td(class: "text-center") { organization.practices_count }
        td(class: "text-center") { organization.password_auth_allowed? ? "Yes" : "No" }
        td(class: "text-center") { organization.email_domains_count }
        td(class: "text-center") { organization.shared_identity_providers.count }
        td(class: "text-center") { organization.dedicated_identity_providers.count }
        td(class: "border-l border-base-content") { render Components::Admin::Index::Actions.new(record: organization) }
      end
    end
  end
end
