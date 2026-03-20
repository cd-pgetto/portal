require "rails_helper"

RSpec.describe InvitationAcceptance do
  let(:host) do
    Class.new do
      include InvitationAcceptance

      def session = {}
    end.new
  end

  let(:user) { build(:user) }

  describe "#accept_pending_invitation_if_any" do
    context "when Invitation.accept_from_session! succeeds" do
      let(:invitation) { build(:invitation) }

      before do
        allow(Invitation).to receive(:accept_from_session!).and_return(invitation)
      end

      it "returns the invitation" do
        expect(host.send(:accept_pending_invitation_if_any, user)).to eq(invitation)
      end
    end

    context "when Invitation.accept_from_session! raises an error" do
      before do
        allow(Invitation).to receive(:accept_from_session!).and_raise(StandardError, "something went wrong")
      end

      it "returns nil" do
        expect(host.send(:accept_pending_invitation_if_any, user)).to be_nil
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/Failed to accept pending invitation: something went wrong/)
        host.send(:accept_pending_invitation_if_any, user)
      end
    end
  end
end
