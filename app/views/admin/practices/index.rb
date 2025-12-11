class Views::Admin::Practices::Index < Views::Base
  def initialize(practices:)
    @practices = practices
  end

  def view_template
    render Components::Admin::Index.new(records: @practices) do |table|
      table.header do
        th { "Name" }
        th { "1st Owner" }
        th { "Organization" }
        th(class: "text-center") { "Members" }
        th(class: "text-center") { "Patients" }
        th(class: "text-center border-l border-base-content") { "Actions" }
      end

      table.row do |practice|
        td { a(href: admin_practice_path(practice), class: "link link-primary") { practice.name } }
        td {
          practice.first_owner ?
            a(href: admin_user_path(practice.first_owner), class: "link link-primary") {
              practice.first_owner.full_name
            } : "-"
        }
        td {
          a(href: admin_organization_path(practice.organization), class: "link link-primary") {
            practice.organization.name
          }
        }
        td(class: "text-center") { practice.users.distinct.count }
        td(class: "text-center") { practice.patients_count }
        td(class: "border-l border-base-content") { render Components::Admin::Index::Actions.new(record: practice) }
      end
    end
  end
end
