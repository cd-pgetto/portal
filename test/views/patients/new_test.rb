require "test_helper"

class PatientsNewTest < ActionView::TestCase
  it "renders new patient form" do
    @patient = Patient.new
    render partial: "patients/form", locals: {patient: Patient.new}
    assert_select "form[action='#{patients_path}'][method='post']"
  end
end
