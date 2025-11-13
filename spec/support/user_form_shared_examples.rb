require "rails_helper"

RSpec.shared_examples "a user form with a title" do
  it "has a title" do
    expect(rendered).to have_text("Sign Up")
  end
end

RSpec.shared_examples "a user form with a cancel link to root" do
  it "has a cancel link to root" do
    expect(rendered).to have_css('a[href="/"]', text: "Cancel")
  end
end

RSpec.shared_examples "a user form with an email field" do
  it "has an email field" do
    expect(rendered).to have_css("label[for='user_email_address']", text: "Email address")
    expect(rendered).to have_css("input[type='email'][required]#user_email_address")
  end
end

RSpec.shared_examples "a user form with a submit button labeled Next" do
  it "has a form with a Next button" do
    expect(rendered).to have_css("form[action='#{users_path}'][method='post']")
    expect(rendered).to have_css("form input[type='submit'][value='Next']")
  end
end

RSpec.shared_examples "a user form with a password field" do
  it "has a password field" do
    expect(rendered).to have_css("label[for='user_password']", text: "Password")
    expect(rendered).to have_css("input[type='password'][required]#user_password")
    # expect(rendered).to have_css("button[data-action='click->password#toggle']")
    # expect(rendered).to have_css("svg[data-password-target='show']")
    # expect(rendered).to have_css("svg[data-password-target='hide']")
    # expect(rendered).to have_css("button[data-action='click->password#refresh']")
  end
end

RSpec.shared_examples "a user form with a first name field" do
  it "has a first name field" do
    expect(rendered).to have_css("label[for='user_first_name']", text: "First name")
    expect(rendered).to have_css("input[type='text'][required]#user_first_name")
  end
end

RSpec.shared_examples "a user form with a last name field" do
  it "has a last name field" do
    expect(rendered).to have_css("label[for='user_last_name']", text: "Last name")
    expect(rendered).to have_css("input[type='text'][required]#user_last_name")
  end
end

RSpec.shared_examples "a user form with a submit button labeled Sign Up" do
  it "has a form with a Sign Up button" do
    expect(rendered).to have_css("form[action='#{users_path}'][method='post']")
    expect(rendered).to have_css("form input[type='submit'][value='Sign Up']")
  end
end
