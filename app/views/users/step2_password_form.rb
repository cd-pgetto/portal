class Views::Users::Step2PasswordForm < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    form_with model: @user, data: {turbo: false}, class: "contents flex-col items-center justify-center" do |form|
      render Views::Shared::ErrorMessages.new(resource: @user)

      form.hidden_field :registration_step

      div(class: "fieldset px-6 py-2") do
        form.label(:email_address, "Email address", class: "fieldset-legend tracking-wide ")
        form.email_field(:email_address, class: "input bg-base-200", readonly: true)
      end

      div(class: "fieldset px-6 py-2") do
        form.label(:password, "Password", class: "fieldset-legend tracking-wide ")
        form.password_field(:password, class: "input", autofocus: true, required: true, autocomplete: "current-password",
          minlength: User::PASSWORD_MIN_LENGTH, maxlength: User::PASSWORD_MAX_LENGTH)
      end

      div(class: "grid grid-cols-2 gap-6 my-5") do
        div(class: "fieldset py-2") do
          form.label(:first_name, "First name", class: "fieldset-legend tracking-wide ")
          form.text_field(:first_name, class: "input", required: true, autocomplete: "given-name")
        end

        div(class: "fieldset py-2") do
          form.label(:last_name, "Last name", class: "fieldset-legend tracking-wide ")
          form.text_field(:last_name, class: "input", required: true, autocomplete: "family-name")
        end
      end

      div(class: "mx-auto text-center my-10") do
        form.submit "Sign Up", class: "btn btn-lg btn-wide btn-primary tracking-wider"
      end
    end
  end
end
