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
class Tooth < ApplicationRecord
  belongs_to :jaw

  has_one_attached :crown_geometry
  has_one_attached :root_geometry

  enum :side, {right: "right", left: "left"}

  delegate :practice_id, to: :jaw

  # US "Universal" tooth numbering scheme
  # UR8 .. UR1 => 1 .. 8
  # UL1 .. UL8 => 9 .. 16
  # LL8 .. LL1 => 17 .. 24
  # LR1 .. LR8 => 25 .. 32
  def universal_number
    if jaw.maxilla?
      right? ? 1 + (8 - number) : 8 + number
    else
      left? ? 17 + (8 - number) : 24 + number
    end
  end
end
