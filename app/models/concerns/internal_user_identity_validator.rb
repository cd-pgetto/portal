# Check to ensure that an internal (Perceptive) user has an authentication using Google Oauth
class InternalUserIdentityValidator < ActiveModel::Validator
  def validate(user)
    return true unless user.internal?
    return true if user.identities&.any? { |identity| identity.identity_provider&.strategy == "google_oauth2" }

    user.errors.add :identities, "must use Google authentication"
  end
end
