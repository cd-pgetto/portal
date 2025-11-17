# frozen_string_literal: true

class Components::IndexTable < Components::Base
  def initialize(records:)
    @records = records
  end

  def view_template
    content_for :title, records.first.class.name.pluralize

    div(class: "w-full") do
      div(class: "flex justify-between items-center mb-5") do
        h1(class: "font-bold text-3xl underline") { records.first.class.name.pluralize }
        a(href: send("new_admin_#{records.first.class.name.underscore}_path"), class: "btn btn-primary") { "New #{records.first.class.name.humanize.downcase}" }
      end

      div(id: records.first.class.name.underscore.pluralize) do
        table(class: "table table-md") do
          thead do
            tr(class: "text-bold") do
              records.first.attributes.keys.each do |attribute|
                th { attribute.humanize }
              end
              th { "Actions" }
            end
          end
          tbody do
            @records&.each do |record|
              tr(class: "hover:bg-base-300") do
                record.attributes.each_value do |value|
                  td { value }
                end
                td do
                  button_to(send("admin_#{record.class.name.underscore}_path", record), method: :delete, class: "btn",
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

# class Views::Admin::Organizations::Index < Views::Base

#   def view_template

#     div(class: "w-full") do
#       div(class: "flex justify-between items-center mb-5") do
#         h1(class: "font-bold text-3xl underline") { "Organizations" }
#         a(href: new_admin_organization_path, class: "btn btn-primary") { "New organization" }
#       end

#       div(id: "organizations") do
#         table(class: "table table-md") do
#           thead do
#             tr(class: "text-bold") do
#               th { "Name" }
#               th { "Subdomain" }
#               th(class: "max-w-24 whitespace-normal") { "Allow Password Auth" }
#               th { "Actions" }
#             end
#           end
#           tbody do
#             @organizations&.each do |organization|
#               tr(class: "hover:bg-base-300") do
#                 td { a(href: admin_organization_path(organization), class: "text-primary font-bold text-lg") { organization.name } }
#                 td { organization.subdomain }
#                 td { organization.password_auth_allowed? ? "Yes" : "No" }
#                 td do
#                   button_to(admin_organization_path(organization), method: :delete, class: "btn",
#                     data: {turbo_confirm: "Are you sure?"}) {
#                       render PhlexIcons::Lucide::Trash.new(class: "size-6 text-error")
#                     }
#                 end
#               end
#             end
#           end
#         end
#       end
#     end
#   end
# end
