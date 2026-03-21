require "test_helper"

describe PasswordsMailer do
  describe "#reset" do
    let(:user) { users(:alice) }
    let(:mail) { PasswordsMailer.reset(user) }

    it "renders the subject" do
      assert_equal "Reset your password", mail.subject
    end

    it "sends to the user's email" do
      assert_equal [user.email_address], mail.to
    end

    it "sends from the default email" do
      assert_equal ["from@example.com"], mail.from
    end

    it "renders the HTML body" do
      assert_includes mail.html_part.body.encoded, "You can reset your password"
      assert_includes mail.html_part.body.encoded, "password reset page"
    end

    it "renders the text body" do
      assert_includes mail.text_part.body.encoded, "You can reset your password"
      assert_includes mail.text_part.body.encoded, "This link will expire in"
    end

    it "delivers the email successfully" do
      assert_emails 1 do
        mail.deliver_now
      end
    end
  end
end
