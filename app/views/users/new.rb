class Views::Users::New < Components::Base
  def initialize(user:, oauth_providers:, password_auth_allowed:)
    @user = user
    @oauth_providers = oauth_providers
    @password_auth_allowed = password_auth_allowed
  end

  attr_reader :user, :oauth_providers, :password_auth_allowed

  def view_template
    content_for :title, "Sign Up"

    div(class: "mx-auto max-w-lg bg-base-200 border-3 shadow-sm") do
      render Components::PerceptiveLockupThemed.new

      div(class: "px-10 pb-10") do
        p(class: "my-6 text-2xl text-center") { "Sign Up" }

        case user.registration_step
        when 1
          render Views::Users::Step1.new(user:)
        when 2
          render Views::Users::Step2.new(user:, oauth_providers:, password_auth_allowed:)
        else
          raise "Invalid registration step: #{user.registration_step}"
        end

        a(href: root_path, class: "link") { "Cancel" }
      end
    end
  end
end
