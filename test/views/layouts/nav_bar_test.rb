require "test_helper"

class LayoutsNavBarTest < ActionView::TestCase
  describe "without an authenticated user" do
    describe "on the sign up page" do
      before {
        view.stub(:controller_name, "users") do
          view.stub(:action_name, "new") do
            render Views::Layouts::NavBar::NavBar.new(current_user: nil)
          end
        end
      }

      it "shows the home button" do
        assert_select "nav.navbar a[href='#{home_path}']"
      end

      it "shows the sign up button as disabled and sign in as active" do
        assert_select "nav.navbar a[href='#{new_user_path}'][disabled]", "Sign Up"
        assert_select "nav.navbar a[href='#{new_session_path}']", "Sign In"
      end
    end

    describe "on the sign in page" do
      before {
        view.stub(:controller_name, "sessions") do
          view.stub(:action_name, "new") do
            render Views::Layouts::NavBar::NavBar.new(current_user: nil)
          end
        end
      }

      it "shows the home button" do
        assert_select "nav.navbar a[href='#{home_path}']"
      end

      it "shows the sign in button as disabled and sign up as active" do
        assert_select "nav.navbar a[href='#{new_user_path}']", "Sign Up"
        assert_select "nav.navbar a[href='#{new_session_path}'][disabled]", "Sign In"
      end
    end
  end

  describe "with an authenticated user" do
    let(:user) { create(:another_user) }

    before { render Views::Layouts::NavBar::NavBar.new(current_user: user) }

    it "shows the home button" do
      assert_select "nav.navbar a[href='#{home_path}']"
    end

    it "shows the user profile and settings links" do
      assert_select "a[href='#{user_path(user)}']", "Profile"
      assert_select "a[href='#{edit_user_path(user)}']", "Settings"
    end
  end
end
