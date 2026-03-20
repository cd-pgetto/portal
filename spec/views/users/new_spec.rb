require "rails_helper"

RSpec.describe "users/new", type: :view do
  describe "step 1" do
    before {
      render Views::Users::New.new(user: User.new(registration_step: 1), identity_providers: [], password_auth_allowed: true)
    }

    it_behaves_like "a user form with a title"
    it_behaves_like "a user form with a cancel link to root"
    it_behaves_like "a user form with an email field"
    it_behaves_like "a user form with a submit button labeled Next"

    it "does not target the top frame so the turbo frame updates inline" do
      expect(rendered).not_to have_css("form[data-turbo-frame='_top']")
    end
  end

  describe "step 2" do
    before {
      render Views::Users::New.new(user: User.new(registration_step: 2), identity_providers: [], password_auth_allowed: true)
    }

    it_behaves_like "a user form with a title"
    it_behaves_like "a user form with a cancel link to root"
    it_behaves_like "a user form with a password field"
    it_behaves_like "a user form with a first name field"
    it_behaves_like "a user form with a last name field"
    it_behaves_like "a user form with a submit button labeled Sign Up"

    it "targets the top frame so a successful sign-up redirects the full page" do
      expect(rendered).to have_css("form[data-turbo-frame='_top']")
    end
  end
end
