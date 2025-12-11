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
require "rails_helper"

RSpec.describe Tooth, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
