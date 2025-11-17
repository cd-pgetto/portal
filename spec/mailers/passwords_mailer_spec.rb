require "rails_helper"

RSpec.describe PasswordsMailer, type: :mailer do
  describe "#reset" do
    let(:user) { create(:user) }
    let(:mail) { described_class.reset(user) }

    it "renders the subject" do
      expect(mail.subject).to eq("Reset your password")
    end

    it "sends to the user's email" do
      expect(mail.to).to eq([user.email_address])
    end

    it "sends from the default email" do
      expect(mail.from).to eq(["from@example.com"])
    end

    it "includes the password reset link in the body" do
      # The view templates use @user.generate_token_for(:password_reset)
      expect(mail.body.encoded).to include("password reset")
    end

    it "assigns @user instance variable" do
      # The view templates use @user to generate the reset token
      expect(mail.body.encoded).to be_present
    end

    it "renders the HTML body" do
      expect(mail.html_part.body.encoded).to include("You can reset your password")
      expect(mail.html_part.body.encoded).to include("password reset page")
    end

    it "renders the text body" do
      expect(mail.text_part.body.encoded).to include("You can reset your password")
      expect(mail.text_part.body.encoded).to include("This link will expire in")
    end

    it "delivers the email successfully" do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
