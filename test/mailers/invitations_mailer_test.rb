require "test_helper"

describe InvitationsMailer do
  describe "#invite" do
    let(:organization) { create(:organization) }
    let(:practice) { create(:practice, name: "Sunrise Dental", organization: organization) }
    let(:inviter) do
      user = create(:another_user)
      create(:organization_member, organization: organization, user: user)
      create(:practice_member, practice: practice, user: user)
      user.reload
    end
    let(:invitation) { create(:invitation, practice: practice, invited_by: inviter, email: "newuser@example.com", role: :dentist) }
    let(:mail) { InvitationsMailer.invite(invitation) }

    before {
      organization
      practice
      inviter
      invitation
    }

    it "renders the subject" do
      assert_equal "You've been invited to join Sunrise Dental", mail.subject
    end

    it "sends to the invitation email address" do
      assert_equal ["newuser@example.com"], mail.to
    end

    it "sends from the default email" do
      assert_equal ["from@example.com"], mail.from
    end

    it "includes the practice name in the HTML body" do
      assert_includes mail.html_part.body.encoded, "Sunrise Dental"
    end

    it "includes the inviter's name in the HTML body" do
      assert_includes mail.html_part.body.encoded, inviter.full_name
    end

    it "includes the role in the HTML body" do
      assert_includes mail.html_part.body.encoded, "dentist"
    end

    it "includes an acceptance link in the HTML body" do
      assert_match %r{/invitations/\S+}, mail.html_part.body.encoded
    end

    it "includes an acceptance link in the text body" do
      assert_match %r{/invitations/\S+}, mail.text_part.body.encoded
    end

    it "includes the expiry notice in the text body" do
      assert_includes mail.text_part.body.encoded, "7 days"
    end

    it "delivers the email successfully" do
      assert_emails 1 do
        mail.deliver_now
      end
    end
  end
end
