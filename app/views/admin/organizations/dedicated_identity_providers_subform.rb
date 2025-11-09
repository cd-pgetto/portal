class Views::Admin::Organizations::DedicatedIdentityProvidersSubform < Views::Base
  def initialize(form:, organization:)
    @form = form
    @organization = organization
  end

  def view_template
    # Dedicated Identity Providers
    div(class: "my-2") do
      #   Nested fields for Dedicated Identity Providers
      div(data: {controller: "nested-form", nested_form_index_value: "NEW_DEDICATED_CRED"}) do
        div(class: "flex flex-row gap-x-4 items-center mb-2") do
          div { "Dedicated Identity Providers" }
          button(class: "btn btn-xs btn-outline", data: {action: "click->nested-form#addNestedForm"}) do
            render PhlexIcons::Lucide::Plus.new(class: "size-4")
          end
        end

        div(data: {nested_form_target: "container"}) do
          form.fields_for :credentials, organization.credentials.dedicated do |cred_fields|
            cred_fields.hidden_field :id
            cred_fields.fields_for :identity_provider do |idp_fields|
              render Views::Admin::Organizations::IdentityProviderFields.new(form: idp_fields, organization: organization)
            end
          end
        end

        # Template for new Dedicated Identity Provider fields
        template(data: {nested_form_target: "template"}) do
          new_credential = organization.credentials.build
          form.fields_for :credentials, new_credential, child_index: "NEW_DEDICATED_CRED" do |cred_fields|
            cred_fields.fields_for :identity_provider, IdentityProvider.new(availability: :dedicated) do |idp_fields|
              render Views::Admin::Organizations::IdentityProviderFields.new(form: idp_fields, organization: organization)
            end
          end
        end
      end
    end
  end

  private

  attr_reader :form, :organization
end
