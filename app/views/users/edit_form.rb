class Views::Users::EditForm < Views::Base
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Pluralize

  def initialize(user:)
    @user = user
  end

  def view_template
    form_with(model: @user, class: "contents") do |form|
      # Show any error messages
      render Views::Shared::ErrorMessages.new(resource: @user)

      # Name
      div(class: "flex") do
        div(class: "my-3 mr-6") do
          form.label(:first_name, "First name", class: "label")
          form.text_field(:first_name, autofocus: @user.errors.none? || @user.errors[:first_name].any?,
            required: true, autocomplete: "given-name", value: @user.first_name,
            class: "input-neutral block shadow-sm rounded-sm border p-1 mt-2 w-full")
        end
        div(class: "my-3") do
          form.label(:last_name, "Last name", class: "label")
          form.text_field(:last_name, autofocus: @user.errors[:last_name].any?, required: true, autocomplete: "family-name",
            value: @user.last_name, class: "input-neutral block shadow-sm rounded-sm border p-1 mt-2 w-full")
        end
      end

      # Email address
      div(class: "my-3") do
        form.label(:email_address, "Email address", class: "label")
        form.email_field(:email_address, autofocus: @user.errors[:email_address].any?, required: true, autocomplete: "email",
          value: @user.email_address, class: "input-neutral block shadow-sm rounded-sm border p-1 mt-2 w-full")
      end

      # Password
      div(class: "my-5") do
        form.label(:password, "Password", class: "label")
        form.password_field(:password, required: true, autofocus: @user.errors[:password].any?, minlength: 12, maxlength: 72,
          class: "input-neutral block shadow-sm rounded-sm border p-1 mt-2 w-full")
      end

      div(class: "w-full my-10 text-center") do
        form.submit class: "btn btn-lg btn-primary rounded-sm"
      end
    end
  end
end
