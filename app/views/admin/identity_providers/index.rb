class Views::Admin::IdentityProviders::Index < Views::Base
  def initialize(identity_providers:)
    @identity_providers = identity_providers
  end

  def view_template
    render Components::Admin::Index.new(records: @identity_providers) do |table|
      table.header do
        th(class: "font-bold") { "Name" }
        th { "Strategy" }
        th { "Availability" }
        th { "Client ID" }
        th { "Client Secret" }
        th(class: "text-center border-l border-base-content") { "Actions" }
      end

      table.row do |identity_provider|
        td { a(href: admin_identity_provider_path(identity_provider), class: "link link-primary") { identity_provider.name } }
        td { identity_provider.strategy }
        td { identity_provider.availability }
        td(title: identity_provider.client_id) { identity_provider.client_id.truncate(10) }
        td(title: identity_provider.client_secret) { identity_provider.client_secret.truncate(10) }
        td(class: "border-l border-base-content") { render Components::Admin::Index::Actions.new(record: identity_provider) }
      end
    end
  end
end
