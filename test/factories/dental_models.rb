# == Schema Information
#
# Table name: dental_models
# Database name: primary
#
#  id         :uuid             not null, primary key
#  model_type :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  patient_id :uuid             not null
#
# Indexes
#
#  index_dental_models_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
FactoryBot.define do
  factory :dental_model do
    patient { nil }
    model_type { "diagnostic" }
    name { model_type.capitalize + " - 2025-12-03 14:02:51" }
  end
end
