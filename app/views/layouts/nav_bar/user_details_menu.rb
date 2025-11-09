class Components::NavBar::UserDetailsMenu < Components::Base
  def initialize(user)
    @user = user
  end

  def view_template
    div(class: "dropdown dropdown-end") do
      div(tabindex: "0", role: "button", class: "btn btn-ghost btn-circle") do
        div(class: "indicator") { render PhlexIcons::Lucide::User.new }
      end

      ul(tabindex: "0", class: "menu menu-md dropdown-content bg-base-100 rounded-box z-1 mt-3 w-40 p-2 shadow") do
        li { a(href: user_path(@user), class: "justify-between") { "Profile" } }
        li { a(href: edit_user_path(@user), class: "justify-between") { "Settings" } }
        li { button_to("Sign Out", sign_out_path, method: :delete, class: "justify-between") }
      end
    end
  end
end
