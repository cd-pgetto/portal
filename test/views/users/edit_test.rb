require "test_helper"

class UsersEditTest < ActionView::TestCase
  let(:user) { create(:another_user) }

  before { render Views::Users::Edit.new(user: user) }

  it "has a cancel link to users#show" do
    assert_select "a[href='#{user_path(user)}']", "Cancel"
  end

  it "has an email field" do
    assert_select "form input[type='email']#user_email_address"
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

  it "has a form with an Update User submit button" do
    assert_select "form[action='#{user_path(user)}'][method='post']"
    assert_select "form input[type='submit'][value='Update User']"
  end
end
