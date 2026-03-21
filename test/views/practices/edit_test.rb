require "test_helper"

class PracticesEditTest < ActionView::TestCase
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, name: "Sunrise Dental", organization: organization) }
  let(:admin) { create_member_in(practice, role: :admin) }

  describe "practice name form" do
    before { render Views::Practices::Edit.new(practice: practice) }

    it "renders the name input pre-filled with the practice name" do
      assert_select "input[value='Sunrise Dental']"
    end

    it "submits to the practice path" do
      assert_select "form[action='#{practice_path(practice)}']"
    end

    it "renders a save button" do
      assert_select "input[type='submit'][value='Save']"
    end
  end

  describe "members section" do
    describe "with no members" do
      before { render Views::Practices::Edit.new(practice: practice) }

      it "renders the no members message" do
        assert_includes rendered, "No members yet."
      end
    end

    describe "with a member" do
      let(:member) { create_member_in(practice) }

      before {
        member
        render Views::Practices::Edit.new(practice: practice)
      }

      it "renders the member's full name" do
        assert_includes rendered, member.full_name
      end

      it "renders a role badge for the member" do
        membership = member.all_practice_memberships.find_by(practice: practice)
        assert_includes rendered, membership.role.humanize
      end

      it "renders a remove button for each role" do
        membership = member.all_practice_memberships.find_by(practice: practice)
        assert_select "form[action='#{practice_membership_path(practice, membership)}']"
      end
    end

    describe "with multiple members" do
      let(:jones) { create_member_in(practice) }
      let(:anderson) do
        u = create(:another_user, first_name: "Bob", last_name: "Anderson")
        create(:organization_member, organization: organization, user: u)
        create(:practice_member, practice: practice, user: u)
        u.reload
      end

      before {
        jones
        anderson
        render Views::Practices::Edit.new(practice: practice)
      }

      it "renders members sorted by last name then first name" do
        anderson_pos = rendered.index("Anderson")
        jones_pos = rendered.index("Jones")
        assert anderson_pos < jones_pos
      end
    end

    describe "with a member who has multiple roles" do
      let(:member) { create_member_in(practice) }

      before {
        member.all_practice_memberships.create!(practice: practice, role: :dentist)
        render Views::Practices::Edit.new(practice: practice)
      }

      it "renders all role badges for the member in a single row" do
        assert_equal 1, rendered.scan(/<td[^>]*>\s*#{Regexp.escape(member.full_name)}\s*<\/td>/).count
        assert_includes rendered, "Member"
        assert_includes rendered, "Dentist"
      end
    end
  end

  describe "pending invitations section" do
    describe "with no pending invitations" do
      before { render Views::Practices::Edit.new(practice: practice) }

      it "does not render a pending invitations section" do
        assert_not_includes rendered, "Pending Invitations"
      end
    end

    describe "with pending invitations" do
      let(:invitation) { create(:invitation, practice: practice, invited_by: admin, email: "newuser@example.com", role: :dentist) }

      before {
        invitation
        render Views::Practices::Edit.new(practice: practice)
      }

      it "renders the invitation email" do
        assert_includes rendered, "newuser@example.com"
      end

      it "renders the invitation role" do
        assert_includes rendered, "Dentist"
      end

      it "renders the inviter's name" do
        assert_includes rendered, admin.full_name
      end

      it "renders a cancel button linking to the invitation" do
        assert_select "form[action='#{practice_invitation_path(practice, invitation)}']"
        assert_includes rendered, "Cancel"
      end
    end

    describe "with an accepted invitation" do
      let(:invitation) { create(:invitation, :accepted, practice: practice, invited_by: admin, email: "accepted@example.com") }

      before {
        invitation
        render Views::Practices::Edit.new(practice: practice)
      }

      it "does not render accepted invitations" do
        assert_not_includes rendered, "accepted@example.com"
      end
    end
  end

  describe "invite user form" do
    before { render Views::Practices::Edit.new(practice: practice) }

    it "renders the invitation form" do
      assert_select "form[action='#{practice_invitations_path(practice)}']"
    end

    it "renders an email field" do
      assert_select "input[type='email']"
    end

    it "renders invitable role options" do
      PracticeMember::REGULAR_ROLES.each do |role|
        assert_select "select option", text: role.humanize
      end
    end

    it "does not include owner or admin in invitable roles" do
      assert_select "select[name='invitation[role]'] option", text: "Owner", count: 0
      assert_select "select[name='invitation[role]'] option", text: "Admin", count: 0
    end

    it "renders a send invitation button" do
      assert_select "input[type='submit'][value='Send Invitation']"
    end
  end
end
