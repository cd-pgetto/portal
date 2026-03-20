require "rails_helper"

RSpec.describe "Practice::Memberships", type: :request do
  let(:organization) { create(:organization) }
  let(:practice) { create(:practice, organization: organization) }
  let(:admin) { create(:user, organization: organization, practices: [practice]) }
  let!(:member) { create(:another_user, organization: organization, practices: [practice]) }

  before do
    admin.all_practice_memberships.find_by(practice: practice).update!(role: :admin)
    sign_in_as(admin, attributes_for(:user)[:password])
  end

  describe "POST /practices/:practice_id/memberships" do
    let(:existing_user) { create(:dr_sue, organization: organization) }

    it "adds a role for an existing user" do
      expect {
        post practice_memberships_path(practice), params: {practice_member: {email_address: existing_user.email_address, role: "dentist"}}
      }.to change { practice.members.count }.by(1)
    end

    it "redirects to the practice edit page with a notice including the role and name" do
      post practice_memberships_path(practice), params: {practice_member: {email_address: existing_user.email_address, role: "dentist"}}
      expect(response).to redirect_to(edit_practice_path(practice))
      expect(flash[:notice]).to include("Dentist")
      expect(flash[:notice]).to include(existing_user.full_name)
    end

    it "can add a second role to an existing member" do
      expect {
        post practice_memberships_path(practice), params: {practice_member: {email_address: member.email_address, role: "dentist"}}
      }.to change { practice.members.count }.by(1)
    end

    context "when the user already has that role in the practice" do
      it "redirects to the edit page with an alert" do
        existing_role = member.all_practice_memberships.find_by(practice: practice).role
        post practice_memberships_path(practice), params: {practice_member: {email_address: member.email_address, role: existing_role}}
        expect(response).to redirect_to(edit_practice_path(practice))
        expect(flash[:alert]).to be_present
      end

      it "does not add a duplicate membership" do
        existing_role = member.all_practice_memberships.find_by(practice: practice).role
        expect {
          post practice_memberships_path(practice), params: {practice_member: {email_address: member.email_address, role: existing_role}}
        }.not_to change { practice.members.count }
      end
    end

    context "when the user does not exist" do
      it "redirects with an alert" do
        post practice_memberships_path(practice), params: {practice_member: {email_address: "nobody@example.com", role: "member"}}
        expect(response).to redirect_to(edit_practice_path(practice))
        expect(flash[:alert]).to include("No user found")
      end
    end

    context "when signed in as a non-admin member" do
      before do
        delete session_path
        sign_in_as(member, attributes_for(:another_user)[:password])
      end

      it "is not authorized" do
        post practice_memberships_path(practice), params: {practice_member: {email_address: "anyone@example.com", role: "member"}}
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end
  end

  describe "DELETE /practices/:practice_id/memberships/:id" do
    let(:membership) { member.all_practice_memberships.find_by(practice: practice) }

    it "removes the role from the practice" do
      expect { delete practice_membership_path(practice, membership) }
        .to change { practice.members.count }.by(-1)
    end

    it "redirects to the practice edit page with a notice" do
      delete practice_membership_path(practice, membership)
      expect(response).to redirect_to(edit_practice_path(practice))
      expect(flash[:notice]).to include("removed")
    end

    context "when signed in as a non-admin member" do
      before do
        delete session_path
        sign_in_as(member, attributes_for(:another_user)[:password])
      end

      it "is not authorized" do
        delete practice_membership_path(practice, membership)
        expect(response).to redirect_to(home_path)
        expect(flash[:alert]).to include("not authorized")
      end
    end
  end
end
