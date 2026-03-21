# == Schema Information
#
# Table name: teeth
# Database name: primary
#
#  id         :uuid             not null, primary key
#  number     :integer          not null
#  side       :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  jaw_id     :uuid             not null
#
# Indexes
#
#  index_teeth_on_jaw_id  (jaw_id)
#
# Foreign Keys
#
#  fk_rails_...  (jaw_id => jaws.id)
#
FactoryBot.define do
  factory :tooth do
    jaw { nil }
    number { 1 }
  end
end
