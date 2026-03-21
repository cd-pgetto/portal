require "test_helper"

describe DashboardPolicy do
  describe "#show?" do
    it "denies nil user" do
      refute DashboardPolicy.new(nil, :dashboard).show?
    end

    it "denies a regular user" do
      refute DashboardPolicy.new(create(:another_user), :dashboard).show?
    end

    it "permits a system admin" do
      assert DashboardPolicy.new(create_system_admin, :dashboard).show?
    end
  end
end
