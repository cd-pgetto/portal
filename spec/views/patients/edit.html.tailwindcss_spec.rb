require "rails_helper"

RSpec.describe "patients/edit", type: :view do
  let(:patient) { create(:patient_with_practice_and_org) }

  before(:each) { assign(:patient, patient) }

  it "renders the edit patient form" do
    render

    assert_select "form[action=?][method=?]", patient_path(patient), "post" do
    end
  end
end
