class Views::Admin::IdentityProviders::Show < Views::Base
  def initialize(identity_provider:)
    @identity_provider = identity_provider
  end

  def view_template
    content_for :title, "Identity Provider"

    div(class: "md:w-2/3 w-full") do
      h1(class: "font-bold text-2xl") { "Identity Provider" }

      render Views::Admin::IdentityProviders::IdentityProvider.new(identity_provider: @identity_provider)

      a(href: edit_admin_identity_provider_path(@identity_provider), class: "btn btn-accent") { "Edit this identity provider" }
      a(href: admin_identity_providers_path, class: "btn btn-light") { "Back to identity providers" }
      button_to(admin_identity_provider_path(@identity_provider), method: :delete,
        form_class: "sm:inline-block mt-2 sm:mt-0 sm:ml-2", class: "btn btn-error",
        data: {turbo_confirm: "Are you sure?"}) { "Destroy this identity provider" }
    end
  end
end
