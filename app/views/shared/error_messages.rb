class Views::Shared::ErrorMessages < Views::Base
  include Phlex::Rails::Helpers::Pluralize

  def initialize(resource:)
    @resource = resource
  end

  def view_template
    return unless @resource&.errors&.any?

    div(id: "error_messages", class: "bg-error p-4 mt-2 mb-4 rounded-md text-sm text-error-content") do
      p do
        %(The #{@resource.class.name} could not be #{created_or_updated} because of
        #{pluralize(@resource.errors.count, "error")}.)
      end

      ul(class: "px-4 list-disc list-inside text-sm text-error-content") do
        @resource.errors.full_messages.each do |message|
          li { message }
        end
      end
    end
  end

  def created_or_updated
    @resource.persisted? ? "updated" : "created"
  end
end
