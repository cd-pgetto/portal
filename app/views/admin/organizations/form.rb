class Views::Admin::Organizations::Form < Components::Base
  def initialize(organization:)
    @organization = organization
  end

  def view_template
    form_with(model: [:admin, @organization], local: true, class: "contents") do |form|
      render Views::Shared::ErrorMessages.new(resource: @organization)

      fieldset(class: "fieldset bg-base-200 border-base-300 rounded-box w-md border p-4 mb-4") do
        # Org name
        form.label(:name, class: "label tracking-wide ")
        form.text_field(:name, class: "input", required: true)

        # Subdomain
        form.label(:subdomain, class: "label tracking-wide mt-4")
        form.label(:subdomain, class: "input") do
          form.text_field(:subdomain, required: true)
          span(class: "label") { ".perceptiveportal.com" }
        end

        # Email domains
        div(class: "mt-4", data: {controller: "nested-form"}) do
          div(class: "flex flex-row justify-between items-center") do
            form.label(:email_domains, class: "label") { "Email Domains" }
            button(class: "btn btn-xs btn-outline", data: {action: "click->nested-form#addAssociation"}) {
              render PhlexIcons::Lucide::Plus.new(class: "size-4")
            }
          end

          div(data: {nested_form_target: "container"}) do
            form.fields_for(:email_domains) do |email_domain_form|
              render_email_domain_fields(email_domain_form)
            end
          end

          # Template for new email domains
          template(data: {nested_form_target: "template"}) do
            render_email_domain_template(form)
          end
        end

        # OAuth authentication options - requires oauth
        span(class: "label mt-4") { "OAuth Options" }
        form.label(:requires_oauth_authentication, class: "label") do
          form.checkbox(:requires_oauth_authentication, class: "checkbox bg-base-100", id: "parent_checkbox",
            data: {controller: "toggle-checkbox", action: "toggle-checkbox#toggle"})
          plain "Requires OAuth Authentication"
        end

        # OAuth authentication options - requires specified providers (depends on above)
        div(class: "ml-6") do
          form.label(:requires_specified_oauth_providers, class: "label mt-2") do
            form.checkbox(:requires_specified_oauth_providers, class: "checkbox bg-base-100", data: {toggle_checkbox_target: "dependentCheckbox"},
              id: "dependent_checkbox", disabled: !@organization.requires_oauth_authentication)
            plain "Requires Specified OAuth Providers"
          end
        end

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
