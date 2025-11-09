class Views::Admin::Organizations::IdentityProvidersFields < Components::Base
  def initialize(organization:)
    @organization = organization
  end

  #   <fieldset class="flex items-center gap-6 mb-6 p-2 border rounded-md" data-nested-form-item=true>
  #     <%= form.hidden_field :id %>
  #     <%= form.hidden_field :availability, value: "dedicated" %>

  #     <div>
  #       <%= form.label :name %>
  #       <%= form.text_field :name, class: form_field_classes(form.object, :name) %>
  #     </div>

  #     <div>
  #       <%= form.label :strategy %>
  #       <%= form.text_field :strategy, class: form_field_classes(form.object, :strategy) %>
  #     </div>

  #     <div>
  #       <%= form.label :icon_url %>
  #       <%= form.text_field :icon_url, class: form_field_classes(form.object, :icon_url) %>
  #     </div>

  #     <div>
  #       <%= form.label "Client ID" %>
  #       <%= form.text_field :client_id, class: form_field_classes(form.object, :client_id) %>
  #     </div>

  #     <div>
  #       <%= form.label "Client Secret" %>
  #       <%= form.text_field :client_secret, class: form_field_classes(form.object, :client_secret) %>
  #     </div>

  #     <div>
  #       <label class="label"></label>
  #       <%= link_to "X", "#", class: "btn btn-error", data: { action: "click->nested-form#removeNestedForm" } %>
  #       <%= form.hidden_field :_destroy %>
  #     </div>

  #   </fieldset>

  def view_template
    div(class: "nested-fields", data: {new_record: form.object.new_record? ? "true" : "false"}) do
      # fieldset(class: "fieldset border-base-300 rounded-box w-md border p-4 mb-4") do
      fieldset(class: "fieldset bg-base-200 border border-base-300 rounded-box flex items-center gap-6 p-4 mb-4",
        data: {nested_form: {item: true}}) do
        form.hidden_field :id
        form.hidden_field :availability, value: "dedicated"

        if @organization.shared_identity_providers.any?
          # DaisyUI toggle checkbox
          label(for: "use_shared_provider", class: "peer label cursor-pointer gap-2") do
            input(type: "checkbox", id: "use_shared_provider", class: "checkbox bg-base-100 checkbox-bordered mr-2")
            span(class: "label-text font-medium") { "Use an existing shared provider" }
          end

          p(class: "text-xs opacity-60 mt-2") { "Check this box to link an existing shared provider, or leave unchecked to create a new organization-specific provider" }

          # Shared provider form (visible when checked)
          div(class: "mt-4 peer-has-checked:block hidden") do
            render Views::Admin::OrganizationOauthProviders::FormShared.new(form:, organization:, shared_providers:)
          end
        end

        div(class: [("mt-4 peer-has-checked:hidden block" if @shared_providers.any?)]) do
          render Views::Admin::OauthProviders::Form.new(form:, organization:)
        end

        div(class: "inline text-center mt-2") do
          form.submit "Add OAuth Provider", class: "btn btn-primary"
        end
      end
    end
  end
end
