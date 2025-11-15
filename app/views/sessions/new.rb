class Views::Sessions::New < Views::Base
  def initialize(email_address:, identity_providers:, password_auth_allowed:)
    @email_address = email_address
    @identity_providers = identity_providers
    @password_auth_allowed = password_auth_allowed
  end

  attr_reader :email_address, :identity_providers, :password_auth_allowed

  def view_template
    content_for :title, "Sign In"

    turbo_stream.update("flash_messages") { render Views::Shared::FlashMessages.new }

    div(class: "mx-auto max-w-lg bg-base-200 border-3 shadow-sm mb-6") do
      render Views::Layouts::PerceptiveLockupThemed.new

      div(class: "px-10 pb-6") do
        p(class: "my-6 text-2xl text-center") { "Sign In" }

        # The logic here comes from the case where the user is signing in
        # via a subdomain. So even if we don't know their email address we
        # know the organization and it's rules. So if password auth is not
        # allowed then we don't need the email address and will redirect to
        # sign in via Oauth in step 2.
        if password_auth_allowed && !email_address.present?
          render Views::Sessions::Step1.new(email_address:)
        else
          render Views::Sessions::Step2.new(email_address:, identity_providers:, password_auth_allowed:)
        end
      end
    end
  end
end
