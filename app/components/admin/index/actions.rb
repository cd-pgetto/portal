class Components::Admin::Index::Actions < Components::Base
  def initialize(record:)
    @record = record
  end

  def view_template
    div(class: "w-full sm:w-auto flex flex-col sm:flex-row justify-center space-x-4") do
      a(href: send("edit_admin_#{class_name}_path", @record), class: "btn btn-xs") {
        render PhlexIcons::Lucide::Pencil.new(class: "size-4")
      }
      button_to(send("admin_#{class_name}_path", @record), method: :delete,
        class: "btn btn-xs", data: {turbo_confirm: "Are you sure?"}) {
        render PhlexIcons::Lucide::Trash.new(class: "size-4 text-error")
      }
    end
  end

  private

  def class_name
    @record.class.name.underscore
  end
end
