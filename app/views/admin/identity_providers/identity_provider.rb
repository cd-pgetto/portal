class Views::Admin::IdentityProviders::IdentityProvider < Components::Base
  def initialize(identity_provider:)
    @identity_provider = identity_provider
  end

  def view_template
    div(id: dom_id(@identity_provider), class: "w-full sm:w-auto my-5 space-y-5") do
      div do
        strong(class: "block font-bold text-lg mb-1") { @identity_provider.name }
        p(class: "text-base") { "Strategy: #{@identity_provider.strategy}" }
        p(class: "text-base") { "Availability: #{@identity_provider.availability}" }
        p(class: "text-base") { "Client ID: #{@identity_provider.client_id}" }
        p(class: "text-base") { "Client Secret: #{@identity_provider.client_secret}" }
      end
    end
  end
end
