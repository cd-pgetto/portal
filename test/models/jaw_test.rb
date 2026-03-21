require "test_helper"

describe Jaw do
  let(:dental_model) { create(:dental_model, patient: create(:patient_with_practice_and_org)) }
  let(:jaw) { dental_model.jaws.create!(jaw_type: :maxilla) }

  describe "validations" do
    it "is invalid without a jaw_type" do
      j = dental_model.jaws.build(jaw_type: nil)
      refute j.valid?
      assert j.errors[:jaw_type].present?
    end

    it "rejects duplicate jaw_type for the same dental_model" do
      dental_model.jaws.create!(jaw_type: :maxilla)
      duplicate = dental_model.jaws.build(jaw_type: :maxilla)
      refute duplicate.valid?
      assert duplicate.errors[:jaw_type].present?
    end

    it "allows the same jaw_type on a different dental_model" do
      other = create(:dental_model, patient: create(:patient_with_practice_and_org))
      other.jaws.create!(jaw_type: :maxilla)
      assert dental_model.jaws.build(jaw_type: :maxilla).valid?
    end
  end

  describe "enum" do
    it "defines maxilla and mandible values" do
      assert_equal({"maxilla" => "maxilla", "mandible" => "mandible"}, Jaw.jaw_types)
    end

    it "rejects unknown jaw_type values" do
      assert_raises(ArgumentError) { Jaw.new(jaw_type: "incisor") }
    end
  end

  describe "#practice_id" do
    it "delegates to dental_model" do
      assert_equal dental_model.practice_id, jaw.practice_id
    end
  end
end
