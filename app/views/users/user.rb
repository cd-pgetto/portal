class Views::Users::User < Components::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    div(id: dom_id(@user), class: "w-full sm:w-auto my-5 space-y-5") do
      p { @user.full_name + " - " + @user.email_address }
      p { "Failed login attempts: #{@user.failed_login_count}" }
      p { "Organization: " + (@user.organization ? @user.organization.name : "None") }
      p { "Practices: #{@user.practices.map(&:name).join(", ")}" }
    end
  end
end
