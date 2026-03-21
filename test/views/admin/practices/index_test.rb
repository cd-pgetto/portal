require "test_helper"

class AdminPracticesIndexTest < ActionView::TestCase
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, name: "Sunrise Dental", organization: organization) }

  describe "when the practice has no owner" do
    before { render Views::Admin::Practices::Index.new(practices: [practice]) }

    it "renders the practice name with a link" do
      assert_select "a[href='#{admin_practice_path(practice)}']", "Sunrise Dental"
    end

    it "renders a dash for the owner column" do
      assert_includes rendered, "-"
    end

    it "renders the organization name with a link" do
      assert_select "a[href='#{admin_organization_path(organization)}']", organization.name
    end
  end

  describe "when the practice has an owner" do
    let(:owner) { create_member_in(practice, role: :owner) }

    before {
      owner
      render Views::Admin::Practices::Index.new(practices: [practice])
    }

    it "renders the owner's full name with a link to the admin user page" do
      assert_select "a[href='#{admin_user_path(owner)}']", owner.full_name
    end
  end
end
