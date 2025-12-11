require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:new_user_data) {
    {registration_step: 2, first_name: "new_first_name", last_name: "new_last_name",
     email_address: "new.user@example.com", password: attributes_for(:user)[:password].reverse}
  }

  describe "GET /users/:id/show" do
    let(:user) { create(:user) }

    context "when not signed in" do
      it "redirects to sign in page" do
        get user_path(user)

        expect(response).to redirect_to(new_session_path)
      end
    end

    context "when signed in" do
      before { sign_in_as(user, attributes_for(:user)[:password]) }

      it "shows users home page" do
        get user_path(user)

        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.email_address)
      end
    end
  end

  describe "GET /users/new" do
    context "when signed in" do
      let(:user) { create(:user) }

      before { sign_in_as(user, attributes_for(:user)[:password]) }

      # Need authorization for this
      it "redirects to users home" do
        get new_user_path

        expect(response).to redirect_to(home_path)
        expect(flash[:notice]).to include("Please sign out first.")
      end
    end

    context "when not signed in" do
      it "gets new user form" do
        get new_user_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Sign Up")
      end
    end
  end

  describe "POST /users" do
    context "when signed in" do
      let(:user) { create(:user) }

      before { sign_in_as(user, attributes_for(:user)[:password]) }

      it "redirects to users home" do
        post users_path params: {user: new_user_data}

        expect(response).to redirect_to(home_path)
        expect(flash[:notice]).to include("Please sign out first.")
      end
    end

    context "when not signed in" do
      it "with valid data at step 1 renders step 2" do
        post users_path, params: {user: {registration_step: "1", email_address: "new.user@example.com"}}

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Sign Up")
        expect(response.body).to include("First name")
        expect(response.body).to include("Last name")
        expect(response.body).to include("Password")
      end
      it "with valid data at step 2 creates new user" do
        expect do
          post users_path params: {user: new_user_data}
        end.to change(User, :count).by(1)

        # expect(User.last.roles.count).to be >= 1
        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to include("Welcome to Perceptive.")
      end
    end

    context "with invalid data" do
      it "at step 1 shows error" do
        post users_path, params: {user: {registration_step: "1", email_address: "foobar"}}

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to include("Please correct the errors and try again.")
      end
      it "at step 2 does not create user and shows error" do
        expect do
          post users_path, params: {user: {registration_step: "2", first_name: "", last_name: "", email_address: "invalid_email", password: "short"}}
        end.to change(User, :count).by(0)

        expect(response).to have_http_status(:unprocessable_content)
        expect(flash[:alert]).to include("Please correct the errors and try again.")
      end
    end
  end

  describe "GET /users/:id/edit" do
    let(:user) { create(:user) }

    context "when signed in" do
      before { sign_in_as(user, attributes_for(:user)[:password]) }

      it "shows page" do
        get edit_user_path(user)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Edit Profile")
        expect(response.body).to include("First name")
        expect(response.body).to include("Last name")
        expect(response.body).to include("Email address")
        expect(response.body).to include("Update User")
      end
    end
  end

  describe "PUT /users/update" do
    let(:user) { create(:user) }

    context "when signed in" do
      before { sign_in_as(user, attributes_for(:user)[:password]) }

      it "updates user" do
        put user_path(user), params: {user: new_user_data}

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(user_path(user))
        expect(flash[:notice]).to include("Your account was successfully updated.")

        user.reload
        expect(user.first_name).to eq(new_user_data[:first_name])
        expect(user.last_name).to eq(new_user_data[:last_name])
        expect(user.email_address).to eq(new_user_data[:email_address])
        expect(user.authenticate(new_user_data[:password])).to be_truthy
      end

      context "with invalid data" do
        it "does not update user and shows error" do
          put user_path(user), params: {user: {first_name: ""}}

          expect(response).to have_http_status(:unprocessable_content)

          user.reload
          expect(user.first_name).to eq(attributes_for(:user)[:first_name])
        end
      end
    end

    context "when not signed in" do
      it "does not update user and shows error" do
        put user_path(user), params: {user: new_user_data}

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to include("Please sign in first.")

        user.reload
        expect(user.first_name).to eq(attributes_for(:user)[:first_name])
        expect(user.last_name).to eq(attributes_for(:user)[:last_name])
        expect(user.email_address).to eq(attributes_for(:user)[:email_address])
        expect(user.authenticate(attributes_for(:user)[:password])).to be_truthy
      end
    end

    context "when signed in as another user" do
      let(:another_user) { create(:another_user) }
      it "does not update user and shows error" do
        sign_in_as(another_user, attributes_for(:user)[:password])

        put user_path(user), params: {user: new_user_data}
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("You are not authorized to access that page.")

        user.reload
        expect(user.first_name).to eq(attributes_for(:user)[:first_name])
        expect(user.last_name).to eq(attributes_for(:user)[:last_name])
        expect(user.email_address).to eq(attributes_for(:user)[:email_address])
        expect(user.authenticate(attributes_for(:user)[:password])).to be_truthy
      end
    end
  end
end
