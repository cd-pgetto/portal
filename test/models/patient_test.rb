require "test_helper"

describe Patient do
  let(:practice) { create(:practice_with_org) }

  it "is invalid without a chart_number" do
    patient = build(:patient, practice: practice, chart_number: nil)
    refute patient.valid?
    assert patient.errors[:chart_number].present?
  end

  it "auto-generates a unique patient_number on create" do
    patient = create(:patient, practice: practice)
    assert patient.patient_number.present?
  end

  it "generates unique patient_numbers scoped to the practice" do
    patient1 = create(:patient, practice: practice)
    patient2 = create(:patient, practice: practice)
    refute_equal patient1.patient_number, patient2.patient_number
  end
end
