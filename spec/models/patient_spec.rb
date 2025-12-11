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
require "rails_helper"

RSpec.describe Patient, type: :model do
  subject { build(:patient, practice: build(:practice, organization: build(:organization))) }

  describe "validations" do
    it { should validate_presence_of(:chart_number) }
  end

  describe "associations" do
    it { should belong_to(:practice) }
  end

  describe "callbacks" do
    describe "before_validation on create" do
      it "sets a unique patient_number" do
        patient = create(:patient, practice: create(:practice, organization: create(:organization)))
        expect(patient.patient_number).to be_present
      end
    end
  end

  describe "#set_patient_number" do
    it "generates a unique patient_number scoped to the practice" do
      practice = create(:practice, organization: create(:organization))
      patient1 = create(:patient, practice:)
      patient2 = create(:patient, practice:)

      expect(patient1.patient_number).not_to eq(patient2.patient_number)
    end

    xit "runs for a long time before failing to find a unique reference number" do
      practice = create(:practice, organization: create(:organization))

      100000.times do
        create(:patient, practice:)
      end

      expect(Patient.count).to eq(100000)
    end
  end
end
