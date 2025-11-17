# Base Authenticable module
# Uses has_secure_password for password encryption and authentication
module Authenticatable
  extend ActiveSupport::Concern

  included do
    has_secure_password validations: false
    # has_secure_token :auth_token

    def authenticate_password(password)
      user = super if password_auth_allowed? && !locked?
      user.tap { |u| increment_failed_login_count! if !u && self.class.include?(Lockable) }
    end

    def authenticate(password)
      authenticate_password(password)
    end
  end
end
