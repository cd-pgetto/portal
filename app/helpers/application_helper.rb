module ApplicationHelper
  def form_field_classes(record, field)
    base_classes = "block shadow-sm rounded-md border px-3 py-2 mt-2 w-full"
    error_classes = record.errors[field].any? ? "border-red-400 focus:outline-red-600" :
      "border-gray-400 focus:outline-blue-600"
    [base_classes, error_classes]
  end
end
