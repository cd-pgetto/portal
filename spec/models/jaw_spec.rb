# == Schema Information
#
# Table name: jaws
# Database name: primary
#
#  id              :uuid             not null, primary key
#  jaw_type        :enum             default("maxilla"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  dental_model_id :uuid             not null
#
# Indexes
#
#  index_jaws_on_dental_model_id               (dental_model_id)
#  index_jaws_on_dental_model_id_and_jaw_type  (dental_model_id,jaw_type) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (dental_model_id => dental_models.id)
#
require "rails_helper"

RSpec.describe Jaw, type: :model do
  let(:dental_model) { create(:dental_model, patient: create(:patient_with_practice_and_org)) }
  subject { dental_model.jaws.create!(jaw_type: :maxilla) }

  describe "associations" do
    it { is_expected.to belong_to(:dental_model) }
    it { is_expected.to have_many(:teeth).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:jaw_type) }

    it "rejects duplicate jaw_type for the same dental_model" do
      dental_model.jaws.create!(jaw_type: :maxilla)
      duplicate = dental_model.jaws.build(jaw_type: :maxilla)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:jaw_type]).to be_present
    end

    it "allows the same jaw_type on a different dental_model" do
      other_dental_model = create(:dental_model, patient: create(:patient_with_practice_and_org))
      other_dental_model.jaws.create!(jaw_type: :maxilla)
      jaw = dental_model.jaws.build(jaw_type: :maxilla)
      expect(jaw).to be_valid
    end
  end

  describe "enum" do
    it "defines maxilla and mandible values" do
      expect(Jaw.jaw_types).to eq("maxilla" => "maxilla", "mandible" => "mandible")
    end

    it "rejects unknown jaw_type values" do
      expect { Jaw.new(jaw_type: "incisor") }.to raise_error(ArgumentError)
    end
  end

  describe "#practice_id" do
    it "delegates to dental_model" do
      expect(subject.practice_id).to eq(dental_model.practice_id)
    end
  end
end
