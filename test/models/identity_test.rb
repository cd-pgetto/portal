require "test_helper"

describe Identity do
  it "requires a provider_user_id" do
    identity = build(:identity, user: create(:another_user), identity_provider: create(:identity_provider),
      provider_user_id: nil)
    refute identity.valid?
    assert identity.errors[:provider_user_id].present?
  end
end
