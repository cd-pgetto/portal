# == Schema Information
#
# Table name: dental_models
# Database name: primary
#
#  id         :uuid             not null, primary key
#  model_type :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  patient_id :uuid             not null
#
# Indexes
#
#  index_dental_models_on_patient_id  (patient_id)
#
# Foreign Keys
#
#  fk_rails_...  (patient_id => patients.id)
#
require "rails_helper"

RSpec.describe DentalModel, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:patient) }
    it { is_expected.to have_many(:jaws).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:model_type) }
    it { is_expected.to validate_length_of(:jaws).is_at_most(2) }
  end

  describe "#maxilla" do
    it "returns the jaw with jaw_type 'maxilla'" do
      organization = create(:organization)
      practice = create(:practice, organization: organization)
      patient = create(:patient, practice: practice)
      dental_model = create(:dental_model, model_type: "diagnostic", patient: patient)
      maxilla_jaw = dental_model.jaws.create(jaw_type: "maxilla")

      expect(dental_model.maxilla).to eq(maxilla_jaw)
    end
  end

  describe "#mandible" do
    it "returns the jaw with jaw_type 'mandible'" do
      organization = create(:organization)
      practice = create(:practice, organization: organization)
      patient = create(:patient, practice: practice)
      dental_model = create(:dental_model, model_type: "diagnostic", patient: patient)
      mandible_jaw = dental_model.jaws.create(jaw_type: "mandible")

      expect(dental_model.mandible).to eq(mandible_jaw)
    end
  end
end
