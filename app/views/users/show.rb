class Views::Users::Show < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    content_for :title, "User Profile"

    div(class: "mx-auto max-w-md w-full bg-base-100 border-3") do
      div(class: "px-10 pb-10") do
        render Views::Users::User.new(user: @user)

        a(href: edit_user_path(@user), class: "link") { "Edit" }
      end
    end
  end
end
