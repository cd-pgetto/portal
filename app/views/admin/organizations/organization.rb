class Views::Admin::Organizations::Organization < Components::Base
  include Phlex::Rails::Helpers::ActionName

  def initialize(organization:)
    @organization = organization
  end

  def view_template
    div(id: dom_id(@organization), class: "w-full sm:w-auto mb-5 space-y-5") do
      div do
        if action_name == "show"
          p(class: "font-semibold text-2xl") { @organization.name }
        else
          a(href: admin_organization_path(@organization), class: "font-semibold text-xl") { @organization.name }
        end
        p(class: "text-base-content/50") do
          strong { "Subdomain: " }
          plain @organization.subdomain
        end
        p(class: "text-base-content/50") do
          strong { "Only OAuth Authentication: " }
          plain @organization.requires_oauth_authentication? ? "Yes" : "No"
        end
        p(class: "text-base-content/50") do
          strong { "Only Selected OAuth Providers: " }
          plain @organization.requires_specified_oauth_providers? ? "Yes" : "No"
        end
      end
    end
  end
end
