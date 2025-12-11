class Components::Table < Components::Base # Components::Table
  def initialize(records:, header:, row:)
    @records = records
    @header = header
    @row = row
  end

  def view_template
    div(class: "w-full") do
      div(id: @records.first&.class&.name || "index-table") do
        table(class: "table table-md text-left") do
          render Components::Table::Header.new(header: @header)
          render Components::Table::Body.new(records: @records, row: @row)
        end
      end
    end
  end
end
