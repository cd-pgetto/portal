require "rails_helper"

RSpec.describe Views::Practices::Show, type: :view do
  let(:practice) { create(:practice_with_org) }

  context "with patients" do
    let!(:patient) { create(:patient, practice:, chart_number: "C001", dental_models_count: 3) }

    before { render Views::Practices::Show.new(practice:) }

    it "renders a row with a link to the patient" do
      expect(rendered).to have_css("a[href='#{patient_path(patient)}']", text: patient.patient_number)
    end

    it "renders the patient chart number" do
      expect(rendered).to have_text("C001")
    end

    it "renders the patient dental models count" do
      expect(rendered).to have_css("td.text-center", text: "3")
    end

    it "renders zero for scans and plans" do
      expect(rendered).to have_css("td.text-center", text: "0", count: 2)
    end
  end

  context "with no patients" do
    before { render Views::Practices::Show.new(practice:) }

    it "renders an empty tbody" do
      expect(rendered).to have_css("tbody:empty")
    end
  end
end
