class Views::Admin::IdentityProviders::Index < Views::Base
  def initialize(identity_providers:)
    @identity_providers = identity_providers
  end

  def view_template
    content_for :title, "Identity Providers"

    div(class: "w-full") do
      div(class: "flex justify-between items-center") do
        h1(class: "font-bold text-3xl underline") { "Identity Providers" }
        a(href: new_admin_identity_provider_path, class: "btn btn-primary") { "New Identity Provider" }
      end

      div(id: "identity_providers", class: "min-w-full divide-y divide-gray-200 space-y-5") do
        if @identity_providers.any?
          @identity_providers.each do |identity_provider|
            div(class: "flex flex-col sm:flex-row justify-between items-center pb-5 sm:pb-0") do
              render Views::Admin::IdentityProviders::IdentityProvider.new(identity_provider: identity_provider)
              div(class: "w-full sm:w-auto flex flex-col sm:flex-row space-x-2 space-y-2") do
                a(href: admin_identity_provider_path(identity_provider), class: "btn btn-light") { "Show" }
                a(href: edit_admin_identity_provider_path(identity_provider), class: "btn btn-accent") { "Edit" }
                button_to(admin_identity_provider_path(identity_provider), method: :delete, class: "btn btn-error",
                  data: {turbo_confirm: "Are you sure?"}) { "Destroy" }
              end
            end
          end
        else
          p(class: "text-center my-10") { "No identity providers found." }
        end
      end
    end
  end
end
