require "test_helper"

class PatientsShowTest < ActionView::TestCase
  it "renders patient attributes" do
    patient = create(:patient_with_practice_and_org)
    @patient = patient
    render template: "patients/show"
    assert_includes rendered, patient.patient_number
  end
end
