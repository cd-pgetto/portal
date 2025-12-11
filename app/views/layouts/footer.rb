class Views::Layouts::Footer < Components::Base
  def view_template
    div(class: "w-full justify-between") do
      footer(class: "footer footer-horizontal bg-base-200 items-center pt-2 pb-4 px-5 border-t-2 border-primary") do
        aside(class: "grid-flow-col items-center") { p { "Copyright © 2025 Perceptive Technologies, Inc. All right reserved." } }

        nav(class: "grid-flow-col gap-4 justify-self-end") do
          a(class: "link link-hover") { "About Us" }
          a(class: "link link-hover") { "Contact" }
          a(class: "link link-hover") { "Privacy" }
          a(class: "link link-hover") { "Terms" }
        end
      end
    end
  end
end
