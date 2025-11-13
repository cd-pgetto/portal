class Views::Users::User < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    div(id: dom_id(@user), class: "w-full sm:w-auto my-5 space-y-5") do
      p { @user.full_name + " - " + @user.email_address }
    end
  end
end
