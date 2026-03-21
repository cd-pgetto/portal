require "test_helper"

class Practice::MembershipsTest < ActionDispatch::IntegrationTest
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:admin) { create_member_in(practice, role: :admin) }
  let(:member) { create_member_in(practice) }

  before {
    practice
    member
    sign_in_as(admin, USER_PASSWORD)
  }

  describe "POST /practices/:practice_id/memberships" do
    let(:existing_user) do
      u = create(:another_user)
      create(:organization_member, organization: organization, user: u)
      u.reload
    end

    it "adds a role for an existing user" do
      assert_difference -> { practice.members.count }, 1 do
        post practice_memberships_path(practice), params: {practice_member: {email_address: existing_user.email_address, role: "dentist"}}
      end
    end

    it "redirects with notice including the role and name" do
      post practice_memberships_path(practice), params: {practice_member: {email_address: existing_user.email_address, role: "dentist"}}
      assert_redirected_to edit_practice_path(practice)
      assert_includes flash[:notice], "Dentist"
      assert_includes flash[:notice], existing_user.full_name
    end

    it "can add a second role to an existing member" do
      assert_difference -> { practice.members.count }, 1 do
        post practice_memberships_path(practice), params: {practice_member: {email_address: member.email_address, role: "dentist"}}
      end
    end

    describe "when the user already has that role in the practice" do
      it "redirects to the edit page with an alert" do
        existing_role = member.all_practice_memberships.find_by(practice: practice).role
        post practice_memberships_path(practice), params: {practice_member: {email_address: member.email_address, role: existing_role}}
        assert_redirected_to edit_practice_path(practice)
        assert flash[:alert].present?
      end

      it "does not add a duplicate membership" do
        existing_role = member.all_practice_memberships.find_by(practice: practice).role
        assert_no_difference -> { practice.members.count } do
          post practice_memberships_path(practice), params: {practice_member: {email_address: member.email_address, role: existing_role}}
        end
      end
    end

    describe "when the user does not exist" do
      it "redirects with an alert" do
        post practice_memberships_path(practice), params: {practice_member: {email_address: "nobody@example.com", role: "member"}}
        assert_redirected_to edit_practice_path(practice)
        assert_includes flash[:alert], "No user found"
      end
    end

    describe "role restrictions by actor role" do
      let(:target_user) do
        u = create(:another_user)
        create(:organization_member, organization: organization, user: u)
        u.reload
      end

      describe "when signed in as an admin" do
        it "cannot assign the owner role" do
          assert_no_difference -> { practice.members.count } do
            post practice_memberships_path(practice), params: {practice_member: {email_address: target_user.email_address, role: "owner"}}
          end
        end

        it "can assign the admin role" do
          assert_difference -> { practice.members.count }, 1 do
            post practice_memberships_path(practice), params: {practice_member: {email_address: target_user.email_address, role: "admin"}}
          end
        end
      end

      describe "when signed in as an owner" do
        let(:owner) { create_member_in(practice, role: :owner) }

        before do
          delete session_path
          sign_in_as(owner, USER_PASSWORD)
        end

        it "can assign the owner role" do
          assert_difference -> { practice.members.count }, 1 do
            post practice_memberships_path(practice), params: {practice_member: {email_address: target_user.email_address, role: "owner"}}
          end
        end
      end
    end

    describe "when signed in as a non-admin member" do
      before do
        delete session_path
        sign_in_as(member, USER_PASSWORD)
      end

      it "is not authorized" do
        post practice_memberships_path(practice), params: {practice_member: {email_address: "anyone@example.com", role: "member"}}
        assert_redirected_to home_path
        assert_includes flash[:alert], "not authorized"
      end
    end
  end

  describe "DELETE /practices/:practice_id/memberships/:id" do
    let(:membership) { member.all_practice_memberships.find_by(practice: practice) }

    it "removes the role from the practice" do
      assert_difference -> { practice.members.count }, -1 do
        delete practice_membership_path(practice, membership)
      end
    end

    it "redirects to the practice edit page with a notice" do
      delete practice_membership_path(practice, membership)
      assert_redirected_to edit_practice_path(practice)
      assert_includes flash[:notice], "removed"
    end

    describe "when signed in as a non-admin member" do
      before do
        delete session_path
        sign_in_as(member, USER_PASSWORD)
      end

      it "is not authorized" do
        delete practice_membership_path(practice, membership)
        assert_redirected_to home_path
        assert_includes flash[:alert], "not authorized"
      end
    end
  end
end
