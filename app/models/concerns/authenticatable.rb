# Base Authenticable module
# Uses has_secure_password for password encryption and authentication
module Authenticatable
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false
    # has_secure_token :auth_token

    # alias_method :std_authenticate, :authenticate

    def authenticate(password)
      pp "Authenticating user #{email_address}"
      user = super if allows_password_auth?
      user.tap { |u| increment_failed_login_count! if !u && self.class.include?(Lockable) }
    end
  end

  class_methods do
    #   def authenticate_by(attributes)
    #     user = super
    #     if user&.allows_password_auth?
    #       user
    #     else
    #       user&.increment_failed_login_count! if include?(Lockable)
    #       nil
    #     end
    #   end

    private

    # Okay to check password if we have a valid user and they do not require OAuth authentication,
    # and if the user is not locked (assuming the Lockable concern is included)
    def can_authenticate_with_password?(user)
      return false unless user
      return false if user.requires_oauth_authentication?
      return false if include?(Lockable) && user.locked?
      true
    end

    # Mitigate timing attacks when the provided email does not match any user
    # by encrypting a dummy string (comparable to encrypting the provided password)
    def mitigate_timing_attack(password)
      BCrypt::Password.create(password)
      nil
    end
  end
end
