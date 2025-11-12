# == Schema Information
#
# Table name: users
#
#  id                  :uuid             not null, primary key
#  email_address       :string           not null
#  first_name          :string           not null
#  last_name           :string           not null
#  original_first_name :string           not null
#  original_last_name  :string           not null
#  password_digest     :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  encrypts :first_name, :last_name, deterministic: true, ignore_case: true
  encrypts :email_address, deterministic: true, downcase: true

  has_secure_password

  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  PASSWORD_MIN_LENGTH = 12
  PASSWORD_MAX_LENGTH = 72

  validates :password, presence: true, length: {minimum: PASSWORD_MIN_LENGTH, maximum: PASSWORD_MAX_LENGTH},
    if: -> { required_for_existing_or_step(2) && :password_digest_changed? }

  validates :email_address, presence: true, uniqueness: {case_sensitive: false},
    format: {with: URI::MailTo::EMAIL_REGEXP}

  with_options if: -> { required_for_existing_or_step(2) } do
    validates :first_name, presence: true
    validates :last_name, presence: true
    # validates_with InternalUserOauthValidator
  end

  def required_for_existing_or_step(step)
    true || persisted? || (defined?(Current) && Current.signup_step && Current.signup_step >= step)
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
