class Views::Admin::Organizations::DedicatedIdentityProvidersSubform < Views::Base
  def initialize(form:, organization:)
    @form = form
    @organization = organization
  end

  def view_template
    div do
      div(class: "mb-2") { "Dedicated Identity Provider" }

      # Use the existing dedicated IdP or build a new one for the form
      dedicated_idp = organization.dedicated_identity_provider ||
        organization.build_dedicated_identity_provider(type: "OktaIdentityProvider")

      form.fields_for :dedicated_identity_provider, dedicated_idp do |idp_fields|
        render Views::Admin::Organizations::IdentityProviderFields.new(form: idp_fields, organization: organization)
      end
    end
  end

  private

  attr_reader :form, :organization
end
