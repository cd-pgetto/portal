require "test_helper"

class PracticesShowTest < ActionView::TestCase
  let(:practice) { create(:practice_with_org) }

  describe "with patients" do
    let(:patient) { create(:patient, practice: practice, chart_number: "C001", dental_models_count: 3) }

    before {
      patient
      render Views::Practices::Show.new(practice: practice)
    }

    it "renders a link to the patient" do
      assert_select "a[href='#{patient_path(patient)}']", patient.patient_number
    end

    it "renders the patient chart number" do
      assert_includes rendered, "C001"
    end

    it "renders the patient dental models count" do
      assert_select "td.text-center", text: "3"
    end
  end

  describe "with no patients" do
    before { render Views::Practices::Show.new(practice: practice) }

    it "renders an empty tbody" do
      assert_select "tbody" do
        assert_select "tr", count: 0
      end
    end
  end
end
