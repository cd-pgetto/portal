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
  include Authenticatable

  encrypts :first_name, :last_name, deterministic: true, ignore_case: true
  encrypts :email_address, deterministic: true, downcase: true

  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :identities, dependent: :destroy
  has_one :organization_membership, class_name: "OrganizationMember", dependent: :destroy
  has_one :organization, through: :organization_membership

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
    validates_with InternalUserIdentityValidator
  end

  def self.random_password
    SecureRandom.base58(16)
  end

  NUM_REGISTRATION_STEPS = 2
  attr_reader :registration_step

  def registration_step=(step)
    @registration_step = step.to_i
  end

  def next_registration_step
    self.registration_step = (registration_step || 0) + 1
  end

  def required_for_existing_or_step(step)
    persisted? || registration_step.nil? || registration_step >= step
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def password_auth_allowed?
    org = Organization.find_by_email(email_address)
    !org || org.password_auth_allowed?
  end

  def system_admin?
    internal? && organization_membership&.admin?
  end

  def internal?
    organization&.subdomain == "perceptive"
  end

  def organization_admin?
    organization_membership&.admin?
  end
end
