require "rails_helper"

# Statistical note on collision probability (via Patient as the reference model):
#
# Pool size: 32^6 = 1,073,741,824 (~1.07 billion possible IDs)
#
# A large practice with 2,000 new patients/year over 30 years = ~60,000 patients.
# At 100,000 existing IDs (a conservative upper bound):
#
#   P(one attempt collides)          = 100,000 / 1,073,741,824  ≈ 9.3 × 10⁻⁵  (~1 in 10,700)
#   P(all 10 attempts collide/raise) = (9.3 × 10⁻⁵)¹⁰          ≈ 7 × 10⁻⁴⁷
#
# For context, 7 × 10⁻⁴⁷ is roughly 10³³ times smaller than 1/(atoms in the observable universe).
# The raise is effectively unreachable under realistic load.

RSpec.describe ShortReadableRandomID, type: :model do
  let(:practice) { create(:practice_with_org) }
  let(:patient) { Patient.new(chart_number: "C001", practice:) }

  describe "#generate_unique_hrid" do
    it "returns the generated ID when no collision exists" do
      allow(SecureRandom).to receive(:alphanumeric).and_return("ABCDEF")
      allow(Patient).to receive(:find_by).and_return(nil)

      result = patient.generate_unique_hrid(:patient_number, practice_id: practice.id)

      expect(result).to eq("ABCDEF")
    end

    it "retries on collision and returns the next unique ID" do
      allow(SecureRandom).to receive(:alphanumeric).and_return("AAAAAA", "BBBBBB")
      allow(Patient).to receive(:find_by).and_return(instance_double(Patient), nil)

      result = patient.generate_unique_hrid(:patient_number, practice_id: practice.id)

      expect(result).to eq("BBBBBB")
      expect(SecureRandom).to have_received(:alphanumeric).twice
    end

    it "raises after 10 consecutive collisions" do
      allow(SecureRandom).to receive(:alphanumeric).and_return("AAAAAA")
      allow(Patient).to receive(:find_by).and_return(instance_double(Patient))

      expect {
        patient.generate_unique_hrid(:patient_number, practice_id: practice.id)
      }.to raise_error(RuntimeError, /Could not generate a unique id/)

      expect(SecureRandom).to have_received(:alphanumeric).exactly(10).times
    end

    it "only uses characters from ALPHABET" do
      100.times do
        result = patient.generate_unique_hrid(:patient_number, practice_id: practice.id)
        expect(result.chars).to all(be_in(Patient::ALPHABET))
      end
    end
  end
end
