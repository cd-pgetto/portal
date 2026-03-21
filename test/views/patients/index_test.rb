require "test_helper"

class PatientsIndexTest < ActionView::TestCase
  it "renders a list of patients" do
    @patients = [create(:patient_with_practice_and_org), create(:patient_with_practice_and_org)]
    render template: "patients/index"
    assert rendered.present?
  end
end
