class Views::Admin::Organizations::Organization < Components::Base
  include Phlex::Rails::Helpers::ActionName

  def initialize(organization:)
    @organization = organization
  end

  def view_template
    # fieldset(class: "fieldset bg-base-200 border border-base-content rounded-box w-full p-4 mb-4") do
    div(id: dom_id(@organization), class: "w-full bg-base-200 border border-base-content rounded-box sm:w-auto mb-4 p-4") do
      div do
        div(class: "font-semibold text-2xl mb-1") { @organization.name }

        # ul(class: "list rounded-box shadow-md") do
        table(class: "table") do
          tr do
            td { strong { "Subdomain:" } }
            td { @organization.subdomain }
          end

          tr do
            td { strong { "Allow Password Auth:" } }
            td { @organization.password_auth_allowed? ? "Yes" : "No" }
          end

          tr do
            td { strong { "Email Domains:" } }
            td { @organization.email_domains.map(&:domain_name).join(", ") }
          end
        end

        div(class: "text-sm mt-2") { "Shared Identity Providers:" }
        div(class: "space-y-2") do
          @organization.shared_identity_providers.each do |provider|
            ul(class: "list-disc ml-6") do
              li { provider.name + " (" + provider.strategy + ")" }
            end
          end
        end

        div(class: "text-sm mt-2") { "Dedicated Identity Providers:" }
        div(class: "space-y-2") do
          @organization.dedicated_identity_providers.each do |provider|
            ul(class: "list-disc ml-6") do
              li { provider.name + " (" + provider.strategy + ")" }
            end
          end
        end
      end
    end
  end
end
