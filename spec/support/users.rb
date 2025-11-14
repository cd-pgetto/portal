module Users
  def create_internal_user
    user = build(:user, original_first_name: "Super", original_last_name: "User",
      email_address: "super.user@#{attributes_for(:perceptive_io_email_domain)[:domain_name]}")

    google_idp = IdentityProvider.find_by(strategy: :google_oauth2) || create(:google_identity_provider)
    user.identities.build(identity_provider: google_idp, provider_user_id: "123456789")

    perceptive = Organization.find_by(subdomain: "perceptive") || create(:perceptive)
    user.build_organization_membership(organization: perceptive, role: :member)
    user.save!
    user.reload
  end

  def create_system_admin
    user = create_internal_user
    user.organization_membership.update(role: :admin)
    user.reload
  end
end

RSpec.configure do |config|
  config.include Users
end
