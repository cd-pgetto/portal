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
class Patient < ApplicationRecord
  include ShortReadableRandomID

  belongs_to :practice, counter_cache: true
  has_many :dental_models, dependent: :destroy

  validates :chart_number, presence: true
  validates :patient_number, presence: true, uniqueness: {scope: :practice_id}

  before_validation(on: :create) { set_patient_number }

  def set_patient_number
    self.patient_number = generate_unique_hrid(:patient_number, practice_id: practice_id)
  end
end
