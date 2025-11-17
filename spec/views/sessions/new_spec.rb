require "rails_helper"

RSpec.shared_examples "it has a title" do
  it "has a title" do
    expect(rendered).to have_text("Sign In")
  end
end

RSpec.shared_examples "it has a logo image" do
  it "has a logo image" do
    expect(rendered).to have_css("img.theme-dark[src*='perceptive-lockup-white']")
    expect(rendered).to have_css("img.theme-light[src*='perceptive-lockup-dark']")
  end
end

RSpec.shared_examples "it has a new session form" do
  it "has a form to create a new session" do
    expect(rendered).to have_css("form[action='#{session_path}'][method='post']")
  end
end

RSpec.describe "sessions/new", type: :view do
  before {
    render Views::Sessions::New.new(email_address: email_address, identity_providers: identity_providers,
      password_auth_allowed: password_auth_allowed)
  }

  context "sign in step 1 - email form" do
    let(:email_address) { "" }
    let(:identity_providers) { [] }
    let(:password_auth_allowed) { true }

    it_behaves_like "it has a logo image"
    it_behaves_like "it has a title"

    describe "form" do
      it_behaves_like "it has a new session form"

      it "requires an email address" do
        expect(rendered).to have_css("form label[for='email_address']", text: "Email address")
        expect(rendered).to have_css("form input[type='email'][required][autofocus]#email_address")
      end

      it "requires a password" do
        expect(rendered).not_to have_css("form label[for='password']", text: "Password")
        expect(rendered).not_to have_css("form input[type='password'][required]#password")
      end

      it "has a submit button" do
        expect(rendered).to have_css("form input[type='submit'][value='Next']")
      end
    end
  end

  context "sign in step 2" do
    let(:email_address) { "test@example.com" }
    let(:password_auth_allowed) { true }

    context "without identity providers" do
      let(:identity_providers) { [] }

      it_behaves_like "it has a logo image"
      it_behaves_like "it has a title"

      describe "form" do
        it_behaves_like "it has a new session form"

        it "requires an email address" do
          expect(rendered).to have_css("form label[for='email_address']", text: "Email address")
          expect(rendered).to have_css("form input[type='email']#email_address")
        end

        it "requires a password" do
          expect(rendered).to have_css("form label[for='password']", text: "Password")
          expect(rendered).to have_css("form input[type='password'][required]#password")
        end

        it "has a submit button" do
          expect(rendered).to have_css("form input[type='submit'][value='Sign In']")
        end
      end
    end

    context "with an identity provider" do
      let(:identity_providers) {
        [IdentityProvider.find_by(strategy: :google_oauth2) ||
          create(:google_identity_provider)]
      }
      it "has a button to sign in with the identity provider" do
        expect(rendered).to have_css("form button[type='submit']")
        expect(rendered).to have_css("form button img[src*='google-oauth2-icon']")
        expect(rendered).to have_css("form button span", text: "Sign In with Google")
      end

      it "has a divider" do
        expect(rendered).to have_css("span.divider", text: "OR")
      end

      context "with password auth not allowed" do
        let(:password_auth_allowed) { false }

        describe "form" do
          it "does not render a form for a password" do
            expect(rendered).not_to have_css("form[action='#{new_session_path}'][method='post']")
          end

          it "requires an email address" do
            expect(rendered).not_to have_css("form label[for='email_address']", text: "Email address")
            expect(rendered).not_to have_css("form input[type='email'][required]#email_address")
          end

          it "has a submit button" do
            expect(rendered).not_to have_css("form input[type='submit'][value='Sign In']")
          end
        end
      end
    end

    context "with an identity provider" do
      let(:identity_providers) {
        [IdentityProvider.find_by(strategy: :google_oauth2) ||
          create(:google_identity_provider)]
      }
      it "has a button to sign in with the identity provider" do
        expect(rendered).to have_css("form button[type='submit']")
        expect(rendered).to have_css("form button img[src*='google-oauth2-icon']")
        expect(rendered).to have_css("form button span", text: "Sign In with Google")
      end

      it "has a divider" do
        expect(rendered).to have_css("span.divider", text: "OR")
      end

      context "with password authentication not allowed" do
        let(:password_auth_allowed) { false }

        describe "form" do
          it "renders new user form" do
            expect(rendered).not_to have_css("form[action='#{session_path}'][method='post']")
          end

          it "requires an email address" do
            expect(rendered).not_to have_css("form label[for='email_address']", text: "Email address")
            expect(rendered).not_to have_css("form input[type='email'][required]#email_address")
          end

          it "has a submit button" do
            expect(rendered).not_to have_css("form input[type='submit'][value='Sign In']")
          end
        end
      end
    end
  end
end
