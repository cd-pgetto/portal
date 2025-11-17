# == Schema Information
#
# Table name: sessions
# Database name: primary
#
#  id         :uuid             not null, primary key
#  ip_address :string
#  user_agent :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
#
# Indexes
#
#  index_sessions_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Session, type: :model do
  subject { build(:session) }

  describe "associations" do
    it { is_expected.to belong_to(:user).required }
  end

  describe ".ip_address" do
    it "returns the IP address of the session" do
      session = create(:session, ip_address: "192.168.1.1")
      expect(session.ip_address).to eq("192.168.1.1")
    end
  end

  describe ".user_agent" do
    it "returns the user agent of the session" do
      session = create(:session, user_agent: "Mozilla/5.0")
      expect(session.user_agent).to eq("Mozilla/5.0")
    end
  end
end
