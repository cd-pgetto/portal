class Views::Users::Step1 < Views::Base
  def initialize(user:)
    @user = user
  end

  def view_template
    turbo_frame_tag("user_registration_form") do
      form_with model: @user, class: "contents flex-col items-center justify-center" do |form|
        render Views::Shared::ErrorMessages.new(resource: @user)

        form.hidden_field :registration_step

        div(class: "fieldset px-6 py-2") do
          form.label(:email_address, "Email address", class: "fieldset-legend tracking-wide ")
          form.email_field(:email_address, class: "input w-full", required: true, autofocus: true)
        end

        div(class: "mx-auto text-center my-10") do
          form.submit "Next", class: "btn btn-lg btn-wide btn-primary tracking-wider"
        end
      end
    end
  end
end
