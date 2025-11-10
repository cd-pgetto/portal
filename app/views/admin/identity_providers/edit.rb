class Views::Admin::IdentityProviders::Edit < Views::Base
  def initialize(identity_provider:)
    @identity_provider = identity_provider
  end

  def view_template
    content_for :title, "Edit Identity Provider"

    div(class: "md:w-2/3 w-full") do
      h1(class: "font-bold text-4xl") { "Edit Identity Provider" }

      render Views::Admin::IdentityProviders::Form.new(identity_provider: @identity_provider)

      a(href: admin_identity_provider_path(@identity_provider),
        class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium") {
          "Show this identity provider"
        }
      a(href: admin_identity_providers_path,
        class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium") {
          "Back to identity providers"
        }
    end
  end
end
