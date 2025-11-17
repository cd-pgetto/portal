class Views::Users::Edit < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    content_for :title, "Edit Profile"

    div(class: "mx-auto max-w-md w-full bg-base-100 border-3") do
      div(class: "px-10 pb-10") do
        p(class: "mt-6 text-2xl text-center") { "Edit Profile" }
        render Views::Users::EditForm.new(user: @user)

        a(href: user_path(@user), class: "link") { "Cancel" }
      end
    end
  end
end
