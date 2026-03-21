# == Schema Information
#
# Table name: patients
# Database name: primary
#
#  id                  :uuid             not null, primary key
#  chart_number        :string           not null
#  dental_models_count :integer          default(0), not null
#  patient_number      :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  practice_id         :uuid             not null
#
# Indexes
#
#  index_patients_on_practice_id                     (practice_id)
#  index_patients_on_practice_id_and_patient_number  (practice_id,patient_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (practice_id => practices.id)
#
FactoryBot.define do
  factory :patient do
    practice { nil }
    patient_number { "A1B2C3" }
    chart_number { "A1B2C3" }

    factory :patient_with_practice_and_org do
      practice factory: :practice_with_org
      patient_number { "A1B2C3" }
      chart_number { "A1B2C3" }
    end
  end
end
