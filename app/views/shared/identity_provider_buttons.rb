class Views::Shared::IdentityProviderButtons < Views::Base
  def initialize(identity_providers:, action: "Sign In")
    @identity_providers = identity_providers
    @action = action
  end

  attr_reader :identity_providers, :action

  def view_template
    return if identity_providers.none?

    div(class: "flex flex-col text-center mt-6 mb-10") do
      identity_providers.each do |provider|
        button_to("/oauth/#{provider.strategy}", class: "btn btn-outline btn-medium",
          data: {turbo: false}, local: true) do
          img(src: asset_path(provider.icon_url), class: "h-5 w-5")
          span { "#{action} with #{provider.name.titleize}" }
        end
      end
    end
  end
end
