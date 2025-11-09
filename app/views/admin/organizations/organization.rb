class Views::Admin::Organizations::Organization < Components::Base
  include Phlex::Rails::Helpers::ActionName

  def initialize(organization:)
    @organization = organization
  end

  def view_template
    div(id: dom_id(@organization), class: "w-full sm:w-auto mb-5 space-y-5") do
      div do
        if action_name == "show"
          p(class: "font-semibold text-2xl mb-1") { @organization.name }
        else
          a(href: admin_organization_path(@organization), class: "font-semibold text-xl") { @organization.name }
        end

        p(class: "text-base-content/50") do
          strong { "Subdomain: " }
          plain @organization.subdomain
        end

        p(class: "text-base-content/50") do
          strong { "Allow Password Auth: " }
          plain @organization.allows_password_auth ? "Yes" : "No"
        end

        div(class: "text-sm text-gray-600 mt-2") { "Shared Identity Providers:" }
        div(class: "space-y-2") do
          @organization.shared_identity_providers.each do |provider|
            ul(class: "list-disc ml-6") do
              li { provider.name + " (" + provider.strategy + ")" }
            end
          end
        end

        div(class: "text-sm text-gray-600 mt-2") { "Dedicated Identity Providers:" }
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
