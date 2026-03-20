require "rails_helper"

RSpec.describe InvitationsMailer, type: :mailer do
  describe "#invite" do
    let(:organization) { create(:organization) }
    let(:practice) { create(:practice, name: "Sunrise Dental", organization: organization) }
    let(:inviter) { create(:user, organization: organization, practices: [practice]) }
    let(:invitation) { create(:invitation, practice: practice, invited_by: inviter, email: "newuser@example.com", role: :dentist) }
    let(:mail) { described_class.invite(invitation) }

    it "renders the subject" do
      expect(mail.subject).to eq("You've been invited to join Sunrise Dental")
    end

    it "sends to the invitation email address" do
      expect(mail.to).to eq(["newuser@example.com"])
    end

    it "sends from the default email" do
      expect(mail.from).to eq(["from@example.com"])
    end

    it "includes the practice name in the HTML body" do
      expect(mail.html_part.body.encoded).to include("Sunrise Dental")
    end

    it "includes the inviter's name in the HTML body" do
      expect(mail.html_part.body.encoded).to include(inviter.full_name)
    end

    it "includes the role in the HTML body" do
      expect(mail.html_part.body.encoded).to include("dentist")
    end

    it "includes an acceptance link in the HTML body" do
      expect(mail.html_part.body.encoded).to match(%r{/invitations/\S+})
    end

    it "includes an acceptance link in the text body" do
      expect(mail.text_part.body.encoded).to match(%r{/invitations/\S+})
    end

    it "includes the expiry notice in the text body" do
      expect(mail.text_part.body.encoded).to include("7 days")
    end

    it "delivers the email successfully" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
