require "test_helper"

describe ShortReadableRandomID do
  let(:practice) { create(:practice_with_org) }
  let(:patient) { Patient.new(chart_number: "C001", practice: practice) }

  describe "#generate_unique_hrid" do
    it "returns the generated ID when no collision exists" do
      SecureRandom.stub(:alphanumeric, "ABCDEF") do
        Patient.stub(:find_by, nil) do
          assert_equal "ABCDEF", patient.generate_unique_hrid(:patient_number, practice_id: practice.id)
        end
      end
    end

    it "retries on collision and returns the next unique ID" do
      call_count = 0
      ids = ["AAAAAA", "BBBBBB"]
      find_count = 0

      SecureRandom.stub(:alphanumeric, ->(*) { ids[call_count].tap { call_count += 1 } }) do
        Patient.stub(:find_by, ->(*) {
          find_count += 1
          (find_count == 1) ? Patient.new : nil
        }) do
          result = patient.generate_unique_hrid(:patient_number, practice_id: practice.id)
          assert_equal "BBBBBB", result
          assert_equal 2, call_count
        end
      end
    end

    it "raises after 10 consecutive collisions" do
      call_count = 0
      SecureRandom.stub(:alphanumeric, ->(*) {
        call_count += 1
        "AAAAAA"
      }) do
        Patient.stub(:find_by, ->(*) { Patient.new }) do
          assert_raises(RuntimeError) do
            patient.generate_unique_hrid(:patient_number, practice_id: practice.id)
          end
          assert_equal 10, call_count
        end
      end
    end

    it "only uses characters from ALPHABET" do
      100.times do
        result = patient.generate_unique_hrid(:patient_number, practice_id: practice.id)
        assert result.chars.all? { |c| Patient::ALPHABET.include?(c) },
          "Expected all chars in ALPHABET, got: #{result}"
      end
    end
  end
end
