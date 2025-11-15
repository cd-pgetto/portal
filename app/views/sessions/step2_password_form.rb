class Views::Sessions::Step2PasswordForm < Components::Base
  include Phlex::Rails::Helpers::TurboStream

  def initialize(email_address:)
    @email_address = email_address
  end

  def view_template
    form_with url: session_path, class: "contents flex-col items-center justify-center" do |form|
      turbo_stream.update("flash_messages") { render Views::Shared::FlashMessages.new }

      form.hidden_field :sign_in_step, value: 2

      div(class: "fieldset px-6 py-2") do
        form.label(:email_address, "Email address", class: "fieldset-legend tracking-wide ")
        form.hidden_field(:email_address, value: @email_address)
        form.email_field(:email_address, class: "input w-full", value: @email_address)
      end

      div(class: "fieldset px-6 py-2") do
        form.label(:password, "Password", class: "fieldset-legend tracking-wide")
        form.password_field(:password, class: "input w-full", autofocus: true,
          required: true, autocomplete: "current-password",
          minlength: User::PASSWORD_MIN_LENGTH, maxlength: User::PASSWORD_MAX_LENGTH)
      end

      div(class: "mx-auto text-center my-10") do
        form.submit "Sign In", class: "btn btn-lg btn-wide btn-primary tracking-wider"
      end
    end
  end
end
