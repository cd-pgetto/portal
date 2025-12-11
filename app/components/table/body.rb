class Components::Table::Body < Components::Base
  def initialize(records:, row:)
    @records = records
    @row = row
  end

  def view_template
    tbody do
      @records.each do |record|
        tr(class: "hover:bg-base-300") do
          @row.call(record)
        end
      end
    end
  end
end
