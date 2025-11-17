class Components::StackedList < Components::Base
  def view_template
    ul(class: "bg-white shadow overflow-hidden sm:rounded-md max-w-sm mx-auto mt-16") do
      # Item 1
      li do
        div(class: "px-4 py-5 sm:px-6") do
          div(class: "flex items-center justify-between") do
            h3(class: "text-lg leading-6 font-medium text-gray-900") { "Item 1" }
            p(class: "mt-1 max-w-2xl text-sm text-gray-500") { "Description for Item 1" }
          end
          div(class: "mt-4 flex items-center justify-between") do
            p(class: "text-sm font-medium text-gray-500") do
              plain "Status: "
              span(class: "text-green-600") { "Active" }
            end
            a(href: "#", class: "font-medium text-indigo-600 hover:text-indigo-500") { "Edit" }
          end
        end
      end

      # Item 2
      li(class: "border-t border-gray-200") do
        div(class: "px-4 py-5 sm:px-6") do
          div(class: "flex items-center justify-between") do
            h3(class: "text-lg leading-6 font-medium text-gray-900") { "Item 2" }
            p(class: "mt-1 max-w-2xl text-sm text-gray-500") { "Description for Item 2" }
          end
          div(class: "mt-4 flex items-center justify-between") do
            p(class: "text-sm font-medium text-gray-500") do
              plain "Status: "
              span(class: "text-red-600") { "Inactive" }
            end
            a(href: "#", class: "font-medium text-indigo-600 hover:text-indigo-500") { "Edit" }
          end
        end
      end

      # Item 3
      li(class: "border-t border-gray-200") do
        div(class: "px-4 py-5 sm:px-6") do
          div(class: "flex items-center justify-between") do
            h3(class: "text-lg leading-6 font-medium text-gray-900") { "Item 3" }
            p(class: "mt-1 max-w-2xl text-sm text-gray-500") { "Description for Item 3" }
          end
          div(class: "mt-4 flex items-center justify-between") do
            p(class: "text-sm font-medium text-gray-500") do
              plain "Status: "
              span(class: "text-yellow-600") { "Pending" }
            end
            a(href: "#", class: "font-medium text-indigo-600 hover:text-indigo-500") { "Edit" }
          end
        end
      end
    end
  end
end
