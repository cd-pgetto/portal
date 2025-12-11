class Components::Admin::Index < Components::Base
  def initialize(records:, class_name: nil)
    @records = records
    @class_name = records.first&.class&.name || class_name || "Record"
  end

  def view_template(&block)
    vanish(&block)

    content_for :title, title

    div(class: "w-full") do
      div(class: "flex justify-between items-center gap-4 mb-2") do
        h1(class: "font-bold text-2xl") { title }
        a(href: send("new_admin_#{class_name}_path"), class: "btn btn-primary") { "New" }
      end

      render Components::Table.new(records:, header: @header, row: @row)
    end
  end

  def header(&block)
    @header = block
  end

  def row(&block)
    @row = block
  end

  private

  attr_reader :records

  def class_name = @class_name.underscore
  def title = class_name.pluralize.titleize
end
