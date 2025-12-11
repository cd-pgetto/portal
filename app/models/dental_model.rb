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
class DentalModel < ApplicationRecord
  belongs_to :patient, counter_cache: true

  has_many :jaws, dependent: :destroy

  validates :model_type, presence: true
  validates :name, presence: true
  validates :jaws, length: {maximum: 2}

  delegate :practice_id, to: :patient

  def maxilla
    jaws.find_by(jaw_type: "maxilla")
  end

  def mandible
    jaws.find_by(jaw_type: "mandible")
  end
end
