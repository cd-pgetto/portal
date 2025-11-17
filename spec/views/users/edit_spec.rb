require "rails_helper"

RSpec.describe "users/edit", type: :view do
  let(:user) { create(:user) }

  before { render Views::Users::Edit.new(user: user) }

  it "has a cancel link to users#show" do
    expect(rendered).to have_css(%(a[href="#{user_path(user)}"]), text: "Cancel")
  end

  it_behaves_like "a user form with an email field"
  it_behaves_like "a user form with a password field"
  it_behaves_like "a user form with a first name field"
  it_behaves_like "a user form with a last name field"

  it "has a form with a submit button" do
    expect(rendered).to have_css("form[action='#{user_path(user)}'][method='post']")
    expect(rendered).to have_css("form input[type='submit'][value='Update User']")
  end
end
