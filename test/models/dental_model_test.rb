require "test_helper"

describe DentalModel do
  let(:practice) { create(:practice_with_org) }
  let(:patient) { create(:patient, practice: practice) }
  let(:dental_model) { create(:dental_model, model_type: "diagnostic", patient: patient) }

  it "is invalid without a model_type" do
    dm = DentalModel.new(patient: patient)
    refute dm.valid?
    assert dm.errors[:model_type].present?
  end

  it "is invalid with more than 2 jaws" do
    dental_model.jaws.create!(jaw_type: :maxilla)
    dental_model.jaws.create!(jaw_type: :mandible)
    dm = DentalModel.find(dental_model.id)
    dm.jaws.build(jaw_type: :maxilla)
    refute dm.valid?
    assert dm.errors[:jaws].present?
  end

  describe "#maxilla" do
    it "returns the jaw with jaw_type maxilla" do
      maxilla = dental_model.jaws.create!(jaw_type: "maxilla")
      assert_equal maxilla, dental_model.maxilla
    end
  end

  describe "#mandible" do
    it "returns the jaw with jaw_type mandible" do
      mandible = dental_model.jaws.create!(jaw_type: "mandible")
      assert_equal mandible, dental_model.mandible
    end
  end
end
