class Views::Admin::Organizations::Organization < Components::Base
  include Phlex::Rails::Helpers::ActionName

  def initialize(organization:)
    @organization = organization
  end

  def view_template
    div(id: dom_id(@organization), class: "w-full bg-base-200 border border-base-content rounded-box sm:w-auto mt-4 p-4") do
      div do
        div(class: "sm:px-0") do
          p(class: "mt-1 sm:mt-0 text-xl") { @organization.name }
        end

        div(class: "mt-2 border-t border-gray-100") do
          dl(class: "divide-y divide-gray-100") do
            # Subdomain
            div(class: "py-2 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
              dt(class: "opacity-70") { "Subdomain:" }
              dd(class: "mt-1 sm:col-span-2 sm:mt-0") { @organization.subdomain }
            end

            # Password Auth Allowed? (Y/N)
            div(class: "py-2 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
              dt(class: "opacity-70") { "Allow Password Authentication:" }
              dd(class: "mt-1 sm:col-span-2 sm:mt-0") { @organization.password_auth_allowed? ? "Yes" : "No" }
            end

            # Email Domains
            div(class: "py-2 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
              dt(class: "opacity-70") { "Email Domains:" }
              dd(class: "mt-1 sm:col-span-2 sm:mt-0") { @organization.email_domains.map(&:domain_name).join(", ") }
            end

            # Shared Identity Providers
            div(class: "py-2 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
              dt(class: "opacity-70") { "Shared Identity Providers:" }
              dd(class: "mt-1 sm:col-span-2 sm:mt-0") {
                @organization.shared_identity_providers.map { |idp|
                  idp.name + " (" + idp.strategy + " )"
                }.join(", ")
              }
            end

            # Dedicated Identity Providers
            div(class: "pt-2 pb-4 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
              dt(class: "opacity-70") { "Dedicated Identity Providers:" }
              dd(class: "mt-1 sm:col-span-2 sm:mt-0") {
                @organization.dedicated_identity_providers.map { |idp|
                  idp.name + " (" + idp.strategy + " )"
                }.join(", ")
              }
            end

            # Practices
            div(class: "pt-2 pb-4 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-0") do
              dt(class: "opacity-70") { "Practices:" }
              dd(class: "mt-1 sm:col-span-2 sm:mt-0") do
                @organization.practices.each do |practice|
                  a(href: admin_practice_path(practice), class: "text-primary hover:underline mr-4") { practice.name }
                end
              end
            end
          end
        end
      end
    end
  end
end
