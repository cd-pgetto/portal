require "test_helper"

describe Tooth do
  let(:dental_model) { create(:dental_model, patient: create(:patient_with_practice_and_org)) }
  let(:maxilla) { dental_model.jaws.create!(jaw_type: :maxilla) }
  let(:mandible) { dental_model.jaws.create!(jaw_type: :mandible) }

  def tooth(jaw:, side:, number:)
    jaw.teeth.create!(number: number, side: side)
  end

  describe "enum" do
    it "defines right and left values" do
      assert_equal({"right" => "right", "left" => "left"}, Tooth.sides)
    end

    it "rejects unknown side values" do
      assert_raises(ArgumentError) { Tooth.new(side: "center") }
    end
  end

  describe "#practice_id" do
    it "delegates to jaw" do
      t = tooth(jaw: maxilla, side: :right, number: 1)
      assert_equal dental_model.practice_id, t.practice_id
    end
  end

  describe "#universal_number" do
    describe "maxilla (upper jaw)" do
      describe "right side" do
        it "maps number 1 to universal 8" do
          assert_equal 8, tooth(jaw: maxilla, side: :right, number: 1).universal_number
        end

        it "maps number 8 to universal 1" do
          assert_equal 1, tooth(jaw: maxilla, side: :right, number: 8).universal_number
        end
      end

      describe "left side" do
        it "maps number 1 to universal 9" do
          assert_equal 9, tooth(jaw: maxilla, side: :left, number: 1).universal_number
        end

        it "maps number 8 to universal 16" do
          assert_equal 16, tooth(jaw: maxilla, side: :left, number: 8).universal_number
        end
      end
    end

    describe "mandible (lower jaw)" do
      describe "left side" do
        it "maps number 1 to universal 24" do
          assert_equal 24, tooth(jaw: mandible, side: :left, number: 1).universal_number
        end

        it "maps number 8 to universal 17" do
          assert_equal 17, tooth(jaw: mandible, side: :left, number: 8).universal_number
        end
      end

      describe "right side" do
        it "maps number 1 to universal 25" do
          assert_equal 25, tooth(jaw: mandible, side: :right, number: 1).universal_number
        end

        it "maps number 8 to universal 32" do
          assert_equal 32, tooth(jaw: mandible, side: :right, number: 8).universal_number
        end
      end
    end
  end
end
