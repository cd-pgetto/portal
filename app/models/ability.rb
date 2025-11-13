class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, User unless user

    return unless user
    can [:read, :update], User, id: user.id

    return unless user&.organization_membership

    can :read, EmailDomain, organization_id: user.organization_membership.organization_id
    can :read, Organization, id: user.organization_membership.organization_id

    if user.organization_admin?
      can [:create, :update], EmailDomain, organization_id: user.organization_membership.organization_id
      can [:create, :update], IdentityProvider do |identity_provider|
        !identity_provider.shared? &&
          identity_provider.organization_ids.include?(user.organization_membership.organization_id)
      end
      can :update, Organization, id: user.organization_membership.organization_id
      can [:create, :update], Credential,
        organization_id: user.organization_membership.organization_id
    end

    if user.system_admin?
      can :manage, :dashboard

      can :manage, Credential
      can :manage, EmailDomain
      can :manage, Identity
      can :manage, IdentityProvider
      can :manage, Organization
      can :manage, User
    end
  end
end
