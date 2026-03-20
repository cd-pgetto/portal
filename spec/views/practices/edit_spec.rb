require "rails_helper"

RSpec.describe Views::Practices::Edit, type: :view do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, name: "Sunrise Dental", organization: organization) }
  let(:admin) { create(:user, organization: organization, practices: [practice]) }

  before { render Views::Practices::Edit.new(practice: practice) }

  describe "practice name form" do
    it "renders the name input pre-filled with the practice name" do
      expect(rendered).to have_css("input[value='Sunrise Dental']")
    end

    it "submits to the practice path" do
      expect(rendered).to have_css("form[action='#{practice_path(practice)}']")
    end

    it "renders a save button" do
      expect(rendered).to have_css("input[type='submit'][value='Save']")
    end
  end

  describe "members section" do
    context "with no members" do
      it "renders the no members message" do
        expect(rendered).to have_text("No members yet.")
      end
    end

    context "with a member" do
      let!(:member) { create(:another_user, organization: organization, practices: [practice]) }

      before { render Views::Practices::Edit.new(practice: practice) }

      it "renders the member's full name" do
        expect(rendered).to have_text(member.full_name)
      end

      it "renders a role badge for the member" do
        membership = member.all_practice_memberships.find_by(practice: practice)
        expect(rendered).to have_text(membership.role.humanize)
      end

      it "renders a remove button for each role" do
        membership = member.all_practice_memberships.find_by(practice: practice)
        expect(rendered).to have_css("form[action='#{practice_membership_path(practice, membership)}']")
      end
    end

    context "with multiple members" do
      let!(:jones) { create(:another_user, organization: organization, practices: [practice]) }
      let!(:anderson) { create(:user, organization: organization, practices: [practice], email_address: "b@example.com", first_name: "Bob", last_name: "Anderson") }

      before { render Views::Practices::Edit.new(practice: practice) }

      it "renders members sorted by last name then first name" do
        anderson_pos = rendered.index("Anderson")
        jones_pos = rendered.index("Jones")
        expect(anderson_pos).to be < jones_pos
      end
    end

    context "with a member who has some roles" do
      let!(:member) { create(:another_user, organization: organization, practices: [practice]) }

      before { render Views::Practices::Edit.new(practice: practice) }

      it "shows an add role dropdown excluding roles the member already has" do
        membership = member.all_practice_memberships.find_by(practice: practice)
        expect(rendered).not_to have_css(
          "select[name='practice_member[role]'] option[value='#{membership.role}']"
        )
      end

      it "shows roles alphabetically with owner and admin last" do
        option_texts = Nokogiri::HTML(rendered).css("select[name='practice_member[role]'] option").map(&:text)
        regular = option_texts.reject { |t| %w[Owner Admin].include?(t) }
        privileged = option_texts.select { |t| %w[Owner Admin].include?(t) }
        expect(regular).to eq(regular.sort)
        expect(option_texts.last(2)).to match_array(%w[Owner Admin])
        expect(privileged).to eq(option_texts.last(privileged.size))
      end
    end

    context "with a member who has multiple roles" do
      let!(:member) { create(:another_user, organization: organization, practices: [practice]) }

      before do
        member.all_practice_memberships.create!(practice: practice, role: :dentist)
        render Views::Practices::Edit.new(practice: practice)
      end

      it "renders all role badges for the member in a single row" do
        expect(rendered).to have_text(member.full_name, count: 1)
        expect(rendered).to have_text("Member")
        expect(rendered).to have_text("Dentist")
      end
    end
  end

  describe "pending invitations section" do
    context "with no pending invitations" do
      it "does not render a pending invitations section" do
        expect(rendered).not_to have_text("Pending Invitations")
      end
    end

    context "with pending invitations" do
      let!(:invitation) { create(:invitation, practice: practice, invited_by: admin, email: "newuser@example.com", role: :dentist) }

      before { render Views::Practices::Edit.new(practice: practice) }

      it "renders the invitation email" do
        expect(rendered).to have_text("newuser@example.com")
      end

      it "renders the invitation role" do
        expect(rendered).to have_text("Dentist")
      end

      it "renders the inviter's name" do
        expect(rendered).to have_text(admin.full_name)
      end

      it "renders a cancel button linking to the invitation" do
        expect(rendered).to have_css(
          "form[action='#{practice_invitation_path(practice, invitation)}']",
          text: "Cancel"
        )
      end
    end

    context "with an accepted invitation" do
      let!(:invitation) { create(:invitation, :accepted, practice: practice, invited_by: admin, email: "accepted@example.com") }

      before { render Views::Practices::Edit.new(practice: practice) }

      it "does not render accepted invitations" do
        expect(rendered).not_to have_text("accepted@example.com")
      end
    end
  end

  describe "invite user form" do
    it "renders the invitation form" do
      expect(rendered).to have_css("form[action='#{practice_invitations_path(practice)}']")
    end

    it "renders an email field" do
      expect(rendered).to have_css("input[type='email']")
    end

    it "renders invitable role options" do
      PracticeMember::REGULAR_ROLES.each do |role|
        expect(rendered).to have_css("select option", text: role.humanize)
      end
    end

    it "does not include owner or admin in invitable roles" do
      expect(rendered).not_to have_css("select[name='invitation[role]'] option", text: "Owner")
      expect(rendered).not_to have_css("select[name='invitation[role]'] option", text: "Admin")
    end

    it "renders a send invitation button" do
      expect(rendered).to have_css("input[type='submit'][value='Send Invitation']")
    end
  end
end
