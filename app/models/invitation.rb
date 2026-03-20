# == Schema Information
#
# Table name: invitations
# Database name: primary
#
#  id            :uuid             not null, primary key
#  accepted_at   :datetime
#  email         :string           not null
#  role          :enum             default("member"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invited_by_id :uuid             not null
#  practice_id   :uuid             not null
#
# Indexes
#
#  index_invitations_on_invited_by_id                  (invited_by_id)
#  index_invitations_on_practice_id                    (practice_id)
#  index_invitations_on_practice_id_and_email_pending  (practice_id,email) UNIQUE WHERE (accepted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (invited_by_id => users.id)
#  fk_rails_...  (practice_id => practices.id)
#
class Invitation < ApplicationRecord
  belongs_to :practice
  belongs_to :invited_by, class_name: "User"

  generates_token_for :acceptance, expires_in: 7.days do
    accepted_at
  end

  INVITABLE_ROLES = %w[member dentist hygienist assistant].freeze

  enum :role, PracticeMember.roles.slice(*INVITABLE_ROLES)

  normalizes :email, with: ->(e) { e.strip.downcase }

  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :role, presence: true
  validate :email_domain_allowed

  scope :pending, -> { where(accepted_at: nil).where("invitations.created_at > ?", 7.days.ago) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  def accepted? = accepted_at.present?

  def pending? = !accepted? && created_at > 7.days.ago

  def accept!(user)
    transaction do
      OrganizationMember.find_or_create_by!(organization: practice.organization, user: user)
      PracticeMember.find_or_create_by!(practice: practice, user: user, role: role)
      update!(accepted_at: Time.current)
    end
  end

  def self.accept_from_session!(session, user)
    token = session.delete(:invitation_token)
    return unless token
    invitation = find_by_token_for(:acceptance, token)
    return unless invitation&.pending?
    return unless invitation.email == user.email_address
    invitation.accept!(user)
    invitation
  end

  private

  def email_domain_allowed
    return if email.blank?
    unless practice&.organization&.email_allowed?(email)
      errors.add(:email, "domain is not allowed for this organization")
    end
  end
end
