class Views::Admin::IdentityProviders::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(identity_provider:)
    @identity_provider = identity_provider
  end

  def view_template
    form_with(model: @identity_provider, class: "contents") do |form|
      render Views::Shared::ErrorMessages.new(resource: @identity_provider)

      div(class: "my-5") do
        form.label(:name)
        form.text_field(:name, class: form_field_classes(@identity_provider, :name), autofocus: true)
      end

      div(class: "my-5") do
        form.label(:strategy)
        form.text_field(:strategy, class: form_field_classes(@identity_provider, :strategy))
      end

      div(class: "my-5") do
        form.label(:availability)
        form.select(:availability,
          IdentityProvider.availabilities.keys.map { |k| [k.titleize, k] },
          {include_blank: true},
          class: form_field_classes(@identity_provider, :availability))
      end

      div(class: "my-5") do
        form.label(:client_id, "Client ID")
        form.text_field(:client_id, class: form_field_classes(@identity_provider, :client_id))
      end

      div(class: "my-5") do
        form.label(:client_secret, "Client Secret")
        form.text_field(:client_secret, class: form_field_classes(@identity_provider, :client_secret))
      end

      div(class: "inline") do
        form.submit class: "btn btn-primary"
      end
    end
  end

  private

  def form_field_classes(record, field)
    base_classes = "block shadow-sm rounded-md border px-3 py-2 mt-2 w-full"
    error_classes = record.errors[field].any? ? "border-red-400 focus:outline-red-600" :
      "border-gray-400 focus:outline-blue-600"
    [base_classes, error_classes]
  end
end
