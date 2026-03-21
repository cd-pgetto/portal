require "test_helper"

describe Session do
  it "requires a user" do
    session = build(:session, user: nil)
    refute session.valid?
    assert session.errors[:user].present?
  end

  it "stores the ip address" do
    assert_equal "127.0.0.1", sessions(:alice_session).ip_address
  end

  it "stores the user agent" do
    assert_equal "Mozilla/5.0", sessions(:alice_session).user_agent
  end
end
