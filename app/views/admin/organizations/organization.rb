class Views::Admin::Organizations::Organization < Components::Base
  include Phlex::Rails::Helpers::ActionName

  def initialize(organization:)
    @organization = organization
  end

  def view_template
    div(id: dom_id(@organization), class: "w-full bg-base-200 border border-base-content rounded-box sm:w-auto mb-4 p-4") do
      div do
        div(class: "text-xl mb-1") { @organization.name }

        dl(class: "rounded-box shadow-md divide-y") do
          #   <li class="list-row">
          # li(class: "list-row") do
          dt(class: "opacity-70") { "Subdomain:" }
          dd { @organization.subdomain }
          # end

          # li(class: "list-row") do
          dt(class: "opacity-70") { "Allow Password Auth:" }
          dd { @organization.password_auth_allowed? ? "Yes" : "No" }
          # end

          # li(class: "list-row") do
          dt(class: "opacity-70") { "Email Domains:" }
          dd { @organization.email_domains.map(&:domain_name).join(", ") }
          # end

          # li(class: "list-row") do
          dt(class: "opacity-70") { "Shared Identity Providers:" }
          dd(class: "") {
            @organization.shared_identity_providers.map { |idp|
              idp.name + " (" + idp.strategy + " )"
            }.join(", ")
          }
          # end

          # li(class: "list-row") do
          dt(class: "opacity-70") { "Dedicated Identity Providers:" }
          dd(class: "") {
            @organization.dedicated_identity_providers.map { |idp|
              idp.name + " (" + idp.strategy + " )"
            }.join(", ")
          }
          # end
        end
      end
    end

    render Views::Admin::Organizations::StackedList.new
  end
end
