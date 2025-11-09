class Views::Admin::Organizations::Form < Components::Base
  def initialize(organization:)
    @organization = organization
  end

  def view_template
    form_with(model: [:admin, @organization], class: "contents") do |form|
      render Views::Shared::ErrorMessages.new(resource: @organization)

      fieldset(class: "fieldset bg-base-200 border-base-300 rounded-box w-full border p-4 mb-4") do
        # Org name
        form.label(:name, class: "label tracking-wide ")
        form.text_field(:name, class: "input", required: true)

        # Subdomain
        form.label(:subdomain, class: "label tracking-wide mt-4")
        form.label(:subdomain, class: "input") do
          form.text_field(:subdomain, required: true)
          span(class: "label") { ".perceptiveportal.com" }
        end

        # Password authentication option - allows_password_auth
        span(class: "label mt-4") { "Password Authentication" }
        form.label(:allows_password_auth, class: "label") do
          form.checkbox(:allows_password_auth, class: "checkbox bg-base-100", id: "parent_checkbox",
            data: {controller: "toggle-checkbox", action: "toggle-checkbox#toggle"})
          plain "Allows Password Authentication"
        end

        # Shared Identity Providers
        div(class: "my-5") do
          div(class: "mb-2") { "Shared Identity Providers" }
          shared_providers = IdentityProvider.shared.order(:name)
          form.collection_check_boxes(:shared_identity_provider_ids, shared_providers, :id, :name) do |shared_idp|
            div(class: "flex items-center gap-2 mb-2") do
              shared_idp.check_box(class: "checkbox bg-base-100")
              shared_idp.label(class: "label") { shared_idp.text }
            end
          end
        end

        render Views::Admin::Organizations::DedicatedIdentityProvidersSubform.new(form:, organization: @organization)

        div(class: "inline text-center mt-2") do
          form.submit class: "btn btn-primary"
        end
      end
    end
  end

  private

  attr_reader :organization

  def render_email_domain_fields(form)
    div(class: "flex gap-2 items-center mb-2", data: {nested_form_item: true}) do
      render_email_domain_field(form)
      if form.object.persisted?
        form.hidden_field(:_destroy)
        label(class: "label cursor-pointer gap-2") do
          form.checkbox(:_destroy, class: "checkbox checkbox-sm bg-base-100")
          span(class: "text-sm") { "Remove" }
        end
      else
        render_remove_new_record_button(form)
      end
    end
  end

  def render_email_domain_template(form)
    form.fields_for(:email_domains, EmailDomain.new, child_index: "NEW_RECORD") do |email_domain_form|
      div(class: "flex gap-2 items-center mb-2", data: {nested_form_item: true}) do
        render_email_domain_field(email_domain_form)
        render_remove_new_record_button(form)
      end
    end
  end

  def render_email_domain_field(form)
    form.text_field(:domain_name, class: "input input-sm flex-1")
  end

  def render_remove_new_record_button(form)
    button(class: "btn btn-xs btn-ghost", data: {action: "click->nested-form#removeAssociation"}) {
      render PhlexIcons::Lucide::Trash.new(class: "size-4 text-error")
    }
  end
end
