# == Schema Information
#
# Table name: jaws
# Database name: primary
#
#  id              :uuid             not null, primary key
#  jaw_type        :enum             default("maxilla"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  dental_model_id :uuid             not null
#
# Indexes
#
#  index_jaws_on_dental_model_id               (dental_model_id)
#  index_jaws_on_dental_model_id_and_jaw_type  (dental_model_id,jaw_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (dental_model_id => dental_models.id)
#
require "rails_helper"

RSpec.describe Jaw, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
