class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, User unless user

    return unless user
    can [:read, :update], User, id: user.id

    return unless user.organization_membership
    organization_id = user.organization_membership.organization_id

    can :read, EmailDomain, organization_id: organization_id
    can :read, Organization, id: organization_id
    can [:read, :select], Practice do |practice|
      user.practice_memberships.exists?(practice_id: practice.id)
    end
    can [:read, :create, :update], Patient do |patient|
      user.practice_memberships.exists?(practice_id: patient.practice_id)
    end
    can [:read, :create, :update], DentalModel do |dental_model|
      user.practice_memberships.exists?(practice_id: dental_model.practice_id)
    end

    can [:edit, :update], Practice do |practice|
      user.practice_memberships.where(role: [:owner, :admin]).exists?(practice_id: practice.id)
    end

    if user.organization_admin?
      can [:create, :update], EmailDomain, organization_id: organization_id
      can [:create, :update], IdentityProvider do |identity_provider|
        identity_provider.dedicated? && identity_provider.organization_ids.include?(organization_id)
      end
      can :update, Organization, id: organization_id
      can [:create, :update], Credential, organization_id: organization_id
    end

    if user.system_admin?
      can :manage, :dashboard

      can :manage, Credential
      can :manage, EmailDomain
      can :manage, Identity
      can :manage, IdentityProvider
      can :manage, Organization
      can :manage, Practice
      can :manage, User
    end
  end
end
