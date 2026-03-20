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
FactoryBot.define do
  factory :invitation do
    association :practice, factory: :practice_with_org
    association :invited_by, factory: :user
    sequence(:email) { |n| "invitee#{n}@example.com" }
    role { :member }

    trait :accepted do
      accepted_at { Time.current }
    end

    trait :expired do
      created_at { 8.days.ago }
    end
  end
end
