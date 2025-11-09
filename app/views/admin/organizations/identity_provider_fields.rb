class Views::Admin::Organizations::IdentityProviderFields < Views::Base
  def initialize(form:, organization:)
    @form = form
    @organization = organization
  end

  def view_template
    div(class: "nested-fields", data: {new_record: form.object.new_record? ? "true" : "false"}) do
      fieldset(class: "fieldset bg-base-200 border-1 border-neutral rounded-box flex items-center gap-x-6 p-2 mb-2",
        data: {nested_form: {item: true}}) do
        form.hidden_field :id
        form.hidden_field :availability, value: "dedicated"
        div(class: "flex flex-col w-full gap-y-4 mt-2") do
          div(class: "flex flex-row justify-between gap-x-4 w-full") do
            # TODO: CSS to highlight borders of fields with errors, maybe use form_field_classes(form.object, :name)

            div(class: "w-full") do
              form.label(:name, class: "label")
              form.text_field(:name, class: "input w-full", required: true)
            end

            div(class: "w-full") do
              form.label(:strategy, class: "label")
              form.text_field(:strategy, class: "input w-full", required: true)
            end

            div(class: "w-full") do
              form.label(:icon_url, class: "label")
              form.text_field(:icon_url, class: "input w-full")
            end
          end

          div(class: "flex flex-row justify-between gap-x-4 w-full") do
            div(class: "w-full") do
              form.label(:client_id, class: "label") { "Client ID" }
              form.text_field(:client_id, class: "input w-full", required: true)
            end

            div(class: "w-full") do
              form.label(:client_secret, class: "label") { "Client Secret" }
              form.text_field(:client_secret, class: "input w-full", required: true)
            end
          end
        end

        div do
          a(href: "#", class: "btn btn-error btn-sm", data: {action: "click->nested-form#removeNestedForm"}) { "X" }
          form.hidden_field(:_destroy)
        end
      end
    end
  end

  private

  attr_reader :form, :organization
end
