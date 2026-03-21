require "test_helper"

class UsersNewTest < ActionView::TestCase
  describe "step 1" do
    before {
      render Views::Users::New.new(user: User.new(registration_step: 1), identity_providers: [], password_auth_allowed: true)
    }

    it "has a title" do
      assert_includes rendered, "Sign Up"
    end

    it "has a cancel link to root" do
      assert_select "a[href='#{root_path}']", "Cancel"
    end

    it "has an email field" do
      assert_select "form input[type='email']#user_email_address"
    end

    it "has a submit button labeled Next" do
      assert_select "form input[type='submit'][value='Next']"
    end

    it "does not target the top frame" do
      assert_select "form[data-turbo-frame='_top']", count: 0
    end
  end

  describe "step 2" do
    before {
      render Views::Users::New.new(user: User.new(registration_step: 2), identity_providers: [], password_auth_allowed: true)
    }

    it "has a title" do
      assert_includes rendered, "Sign Up"
    end

    it "has a cancel link to root" do
      assert_select "a[href='#{root_path}']", "Cancel"
    end

    it "has a password field" do
      assert_select "form input[type='password']"
    end

    it "has a first name field" do
      assert_select "form input#user_first_name"
    end

    it "has a last name field" do
      assert_select "form input#user_last_name"
    end

    it "has a submit button labeled Sign Up" do
      assert_select "form input[type='submit'][value='Sign Up']"
    end

    it "targets the top frame" do
      assert_select "form[data-turbo-frame='_top']"
    end
  end
end
