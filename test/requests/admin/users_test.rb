require "test_helper"

class Admin::UsersTest < ActionDispatch::IntegrationTest
  let(:valid_attributes) {
    {first_name: "first_name", last_name: "last_name",
     email_address: "user@example.com", password: USER_PASSWORD}
  }
  let(:invalid_attributes) {
    {first_name: "", last_name: "", email_address: "invalid_email", password: "short"}
  }

  before { sign_in_as_admin }

  describe "GET /admin/users" do
    it "renders a successful response" do
      User.create!(valid_attributes)
      get admin_users_url
      assert_response :success
    end

    it "lists all users" do
      user_a = User.create!(valid_attributes)
      user_b = User.create!(valid_attributes.merge(email_address: "other@example.com"))
      get admin_users_url
      assert_includes response.body, user_a.first_name
      assert_includes response.body, user_b.first_name
    end
  end

  describe "GET /admin/users/:id" do
    it "renders a successful response" do
      user = User.create!(valid_attributes)
      get admin_user_url(user)
      assert_response :success
    end
  end

  describe "GET /admin/users/new" do
    it "renders a successful response" do
      get new_admin_user_url
      assert_response :success
    end
  end

  describe "GET /admin/users/:id/edit" do
    it "renders a successful response" do
      user = User.create!(valid_attributes)
      get edit_admin_user_url(user)
      assert_response :success
    end
  end

  describe "POST /admin/users" do
    describe "with valid parameters" do
      it "creates a new User" do
        assert_difference -> { User.count }, 1 do
          post admin_users_url, params: {user: valid_attributes}
        end
      end

      it "redirects to the created user" do
        post admin_users_url, params: {user: valid_attributes}
        assert_redirected_to admin_user_url(User.order(:created_at).last)
      end
    end

    describe "with invalid parameters" do
      it "does not create a new User" do
        assert_no_difference -> { User.count } do
          post admin_users_url, params: {user: invalid_attributes}
        end
      end

      it "renders a 422 response" do
        post admin_users_url, params: {user: invalid_attributes}
        assert_response :unprocessable_content
      end
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:new_attributes) {
      {first_name: "new_first_name", last_name: "new_last_name",
       email_address: "new.user@example.com", password: USER_PASSWORD.reverse}
    }

    describe "with valid parameters" do
      it "updates the requested user" do
        user = User.create!(valid_attributes)
        patch admin_user_url(user), params: {user: new_attributes}
        user.reload
        assert_equal "new_first_name", user.first_name
        assert_equal "new.user@example.com", user.email_address
      end

      it "redirects to the user" do
        user = User.create!(valid_attributes)
        patch admin_user_url(user), params: {user: new_attributes}
        assert_redirected_to admin_user_url(user.reload)
      end
    end

    describe "with invalid parameters" do
      it "renders a 422 response" do
        user = User.create!(valid_attributes)
        patch admin_user_url(user), params: {user: invalid_attributes}
        assert_response :unprocessable_content
      end
    end
  end

  describe "DELETE /admin/users/:id" do
    it "destroys the requested user" do
      user = User.create!(valid_attributes)
      assert_difference -> { User.count }, -1 do
        delete admin_user_url(user)
      end
    end

    it "redirects to the users list" do
      user = User.create!(valid_attributes)
      delete admin_user_url(user)
      assert_redirected_to admin_users_url
    end
  end
end
