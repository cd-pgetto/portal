module Users
  # Creates a user with admin membership in an internal organization,
  # satisfying the system_admin? check (internal? && organization_admin?).
  def create_system_admin
    internal_org = Organization.find_by(internal: true) || create(:organization, internal: true)
    user = create(:another_user)
    create(:organization_member, organization: internal_org, user: user, role: :admin)
    user.reload
  end

  # Creates a user with an org membership and a practice membership at the given role.
  def create_member_in(practice, role: :member, factory: :another_user)
    user = create(factory)
    create(:organization_member, organization: practice.organization, user: user)
    create(:practice_member, practice: practice, user: user, role: role)
    user.reload
  end
end

module ActiveSupport
  class TestCase
    include Users
  end
end
