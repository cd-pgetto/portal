require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  let(:new_user_data) {
    {registration_step: 2, first_name: "new_first_name", last_name: "new_last_name",
     email_address: "new.user@example.com", password: USER_PASSWORD.reverse}
  }

  describe "GET /users/:id" do
    let(:user) { create(:another_user) }

    it "redirects to sign in when not signed in" do
      get user_path(user)
      assert_redirected_to new_session_path
    end

    describe "signed in as the same user" do
      before { sign_in_as(user, USER_PASSWORD) }

      it "shows the user's home page" do
        get user_path(user)
        assert_response :success
        assert_includes response.body, user.email_address
      end
    end

    describe "signed in as another user" do
      let(:other_user) { create(:another_user) }
      before { sign_in_as(other_user, USER_PASSWORD) }

      it "is not authorized" do
        get user_path(user)
        assert_redirected_to home_path
        assert_includes flash[:alert], "You are not authorized"
      end
    end
  end

  describe "GET /users/new" do
    describe "when signed in" do
      let(:user) { create(:another_user) }
      before { sign_in_as(user, USER_PASSWORD) }

      it "redirects to users home" do
        get new_user_path
        assert_redirected_to home_path
        assert_includes flash[:notice], "Please sign out first."
      end
    end

    describe "when not signed in" do
      it "gets new user form" do
        get new_user_path
        assert_response :ok
        assert_includes response.body, "Sign Up"
      end
    end
  end

  describe "POST /users" do
    describe "when signed in" do
      let(:user) { create(:another_user) }
      before { sign_in_as(user, USER_PASSWORD) }

      it "redirects to users home" do
        post users_path, params: {user: new_user_data}
        assert_redirected_to home_path
        assert_includes flash[:notice], "Please sign out first."
      end
    end

    describe "when not signed in" do
      it "with valid data at step 1 renders step 2" do
        post users_path, params: {user: {registration_step: "1", email_address: "new.user@example.com"}}
        assert_response :ok
        assert_includes response.body, "Sign Up"
        assert_includes response.body, "First name"
        assert_includes response.body, "Password"
      end

      it "with valid data at step 2 creates new user" do
        assert_difference -> { User.count }, 1 do
          post users_path, params: {user: new_user_data}
        end
        assert response.redirect?
        assert_includes flash[:notice], "Welcome to Perceptive."
      end
    end

    describe "with invalid data" do
      it "at step 1 shows error" do
        post users_path, params: {user: {registration_step: "1", email_address: "foobar"}}
        assert_response :unprocessable_content
        assert_includes flash[:alert], "Please correct the errors and try again."
      end

      it "at step 2 does not create user and shows error" do
        assert_no_difference -> { User.count } do
          post users_path, params: {user: {registration_step: "2", first_name: "", last_name: "", email_address: "invalid_email", password: "short"}}
        end
        assert_response :unprocessable_content
        assert_includes flash[:alert], "Please correct the errors and try again."
      end
    end
  end

  describe "GET /users/:id/edit" do
    let(:user) { create(:another_user) }

    describe "when signed in" do
      before { sign_in_as(user, USER_PASSWORD) }

      it "shows the edit page" do
        get edit_user_path(user)
        assert_response :ok
        assert_includes response.body, "Edit Profile"
        assert_includes response.body, "First name"
        assert_includes response.body, "Update User"
      end
    end

    it "redirects to sign in when not signed in" do
      get edit_user_path(user)
      assert_redirected_to new_session_path
    end

    describe "when signed in as another user" do
      let(:other_user) { create(:another_user) }
      before { sign_in_as(other_user, USER_PASSWORD) }

      it "is not authorized" do
        get edit_user_path(user)
        assert_redirected_to home_path
        assert_includes flash[:alert], "You are not authorized"
      end
    end
  end

  describe "PUT /users/:id" do
    let(:user) { create(:another_user) }

    describe "when signed in" do
      before { sign_in_as(user, USER_PASSWORD) }

      it "updates user" do
        put user_path(user), params: {user: new_user_data}
        assert_redirected_to user_path(user)
        assert_includes flash[:notice], "Your account was successfully updated."
        user.reload
        assert_equal new_user_data[:first_name], user.first_name
        assert_equal new_user_data[:email_address], user.email_address
        assert user.authenticate(new_user_data[:password])
      end

      it "does not update with invalid data" do
        put user_path(user), params: {user: {first_name: ""}}
        assert_response :unprocessable_content
        user.reload
        assert_not_equal "", user.first_name
      end
    end

    it "redirects to sign in when not signed in" do
      put user_path(user), params: {user: new_user_data}
      assert_redirected_to new_session_path
      assert_includes flash[:notice], "Please sign in first."
    end

    describe "when signed in as another user" do
      let(:other_user) { create(:another_user) }

      it "is not authorized" do
        sign_in_as(other_user, USER_PASSWORD)
        put user_path(user), params: {user: new_user_data}
        assert_redirected_to home_path
        assert_includes flash[:alert], "You are not authorized"
      end
    end
  end
end
