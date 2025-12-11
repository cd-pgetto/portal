# == Schema Information
#
# Table name: practice_members
# Database name: primary
#
#  id          :uuid             not null, primary key
#  role        :enum             default("member"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  practice_id :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_practice_members_on_practice_id  (practice_id)
#  index_practice_members_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (practice_id => practices.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :practice_member do
    practice { nil }
    user { nil }
    role { "member" }
  end
end
