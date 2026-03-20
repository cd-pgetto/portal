class Views::Invitations::Show < Views::Base
  def initialize(invitation:, user:, identity_providers:, password_auth_allowed:)
    @invitation = invitation
    @user = user
    @identity_providers = identity_providers
    @password_auth_allowed = password_auth_allowed
  end

  attr_reader :user, :identity_providers, :password_auth_allowed

  def view_template
    content_for :title, "Join #{@invitation.practice.name}"

    div(class: "flex flex-col items-center justify-center min-h-screen") do
      div(class: "card bg-base-100 shadow-xl w-full max-w-md") do
        div(class: "card-body gap-4") do
          h1(class: "card-title text-2xl") { "You're invited!" }

          p do
            plain "#{@invitation.invited_by.full_name} has invited you to join "
            strong { @invitation.practice.name }
            plain " as a #{@invitation.role}."
          end

          div(class: "divider") { "Create an account to accept" }

          render Views::Shared::AuthOptions.new(user:, identity_providers:, password_auth_allowed:)

          div(class: "divider") { "Already have an account?" }
          a(href: new_session_path, class: "btn btn-outline btn-block") { "Sign In" }
        end
      end
    end
  end
end
