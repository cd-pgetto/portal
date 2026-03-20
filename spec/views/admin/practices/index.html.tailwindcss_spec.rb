require "rails_helper"

RSpec.describe Views::Admin::Practices::Index, type: :view do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, name: "Sunrise Dental", organization: organization) }

  context "when the practice has no owner" do
    before { render described_class.new(practices: [practice]) }

    it "renders the practice name with a link" do
      expect(rendered).to have_css("a[href='#{admin_practice_path(practice)}']", text: "Sunrise Dental")
    end

    it "renders a dash for the owner column" do
      expect(rendered).to have_text("-")
    end

    it "renders the organization name with a link" do
      expect(rendered).to have_css("a[href='#{admin_organization_path(organization)}']", text: organization.name)
    end
  end

  context "when the practice has an owner" do
    let(:owner) { create(:user, organization: organization, practices: [practice]) }

    before do
      owner.practice_memberships.find_by(practice: practice).update!(role: :owner)
      render described_class.new(practices: [practice])
    end

    it "renders the owner's full name with a link to the admin user page" do
      expect(rendered).to have_css("a[href='#{admin_user_path(owner)}']", text: owner.full_name)
    end

    it "does not render a dash for the owner column" do
      expect(rendered).not_to have_css("td", text: "-")
    end
  end
end
