require "rails_helper"

RSpec.describe "layouts/nav_bar/user_menu", type: :view do
  let(:user) { create(:user) }

  describe "without an authenticated user" do
    before {}

    context "on the sign up page" do
      before do
        allow(view).to receive(:controller_name).and_return("users")
        allow(view).to receive(:action_name).and_return("new")
        render Views::Layouts::NavBar::UserMenu.new(current_user: nil)
      end

      it "shows the sign up and sign in buttons" do
        expect(rendered).to have_selector("ul.menu") do |ul|
          expect(ul).to have_selector("li.mx-2 > a.btn.btn-accent[href='#{new_user_path}'][disabled]", text: "Sign Up")
          expect(ul).to have_selector("li.mx-2 > a.btn.btn-accent[href='#{new_session_path}']", text: "Sign In")
        end
      end
    end

    context "on the sign in page" do
      before do
        allow(view).to receive(:controller_name).and_return("sessions")
        allow(view).to receive(:action_name).and_return("new")
        render Views::Layouts::NavBar::UserMenu.new(current_user: nil)
      end

      it "shows the sign up and sign in buttons" do
        expect(rendered).to have_selector("ul.menu") do |ul|
          expect(ul).to have_selector("li.mx-2 > a.btn.btn-accent[href='#{new_user_path}']", text: "Sign Up")
          expect(ul).to have_selector("li.mx-2 > a.btn.btn-accent[href='#{new_session_path}'][disabled]",
            text: "Sign In")
        end
      end
    end
  end

  describe "with an authenticated user" do
    before { render Views::Layouts::NavBar::UserMenu.new(current_user: user) }

    it "shows the notifications and user details menu" do
      expect(rendered).to have_selector("ul.menu") do |ul|
        expect(ul).to have_selector("li#notifications > button > div.indicator")
        expect(ul).to have_selector("li#user-details-menu") do |li|
          expect(li).to have_selector("div > ul.menu.dropdown-content") do |dropdown|
            expect(dropdown).to have_selector("a[href='#{user_path(user)}']", text: "Profile")
            expect(dropdown).to have_selector("a[href='#{edit_user_path(user)}']", text: "Settings")
          end
        end
      end
    end
  end
end
