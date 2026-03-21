require "test_helper"

class PatientsEditTest < ActionView::TestCase
  it "renders the edit patient form" do
    patient = create(:patient_with_practice_and_org)
    @patient = patient
    render partial: "patients/form", locals: {patient: patient}
    assert_select "form[action='#{patient_path(patient)}'][method='post']"
  end
end
