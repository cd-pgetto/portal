class Components::Table::Header < Components::Base
  def initialize(header:)
    @header = header
  end

  def view_template
    thead do
      tr(class: "border-b border-base-content") do
        @header.call
      end
    end
  end
end
