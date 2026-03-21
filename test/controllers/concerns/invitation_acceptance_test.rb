require "test_helper"

class InvitationAcceptanceTest < ActiveSupport::TestCase
  let(:host) do
    Class.new do
      include InvitationAcceptance

      def session = {}
      def flash = @flash ||= ActionDispatch::Flash::FlashHash.new
    end.new
  end

  let(:user) { build(:user) }

  describe "#accept_pending_invitation_if_any" do
    describe "when Invitation.accept_from_session! succeeds" do
      let(:invitation) { build(:invitation) }

      it "returns the invitation" do
        Invitation.stub(:accept_from_session!, invitation) do
          assert_equal invitation, host.send(:accept_pending_invitation_if_any, user)
        end
      end
    end

    describe "when Invitation.accept_from_session! raises an error" do
      let(:raiser) { ->(*) { raise StandardError, "something went wrong" } }

      it "returns nil" do
        Invitation.stub(:accept_from_session!, raiser) do
          assert_nil host.send(:accept_pending_invitation_if_any, user)
        end
      end

      it "logs the error" do
        logged = []
        logger_stub = Object.new
        logger_stub.define_singleton_method(:error) { |msg| logged << msg }

        Invitation.stub(:accept_from_session!, raiser) do
          Rails.stub(:logger, logger_stub) do
            host.send(:accept_pending_invitation_if_any, user)
          end
        end

        assert_match(/Failed to accept pending invitation: something went wrong/, logged.first)
      end

      it "sets a flash alert" do
        Invitation.stub(:accept_from_session!, raiser) do
          host.send(:accept_pending_invitation_if_any, user)
        end

        assert host.flash.alert.present?
      end
    end
  end
end
