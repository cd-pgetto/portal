# == Schema Information
#
# Table name: teeth
# Database name: primary
#
#  id         :uuid             not null, primary key
#  number     :integer          not null
#  side       :enum             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  jaw_id     :uuid             not null
#
# Indexes
#
#  index_teeth_on_jaw_id  (jaw_id)
#
# Foreign Keys
#
#  fk_rails_...  (jaw_id => jaws.id)
#
require "rails_helper"

RSpec.describe Tooth, type: :model do
  let(:dental_model) { create(:dental_model, patient: create(:patient_with_practice_and_org)) }
  let(:maxilla) { dental_model.jaws.create!(jaw_type: :maxilla) }
  let(:mandible) { dental_model.jaws.create!(jaw_type: :mandible) }

  def tooth(jaw:, side:, number:)
    jaw.teeth.create!(number:, side:)
  end

  describe "associations" do
    subject { tooth(jaw: maxilla, side: :right, number: 1) }

    it { is_expected.to belong_to(:jaw) }
    it { is_expected.to have_one_attached(:crown_geometry) }
    it { is_expected.to have_one_attached(:root_geometry) }
  end

  describe "enum" do
    it "defines right and left values" do
      expect(Tooth.sides).to eq("right" => "right", "left" => "left")
    end

    it "rejects unknown side values" do
      expect { Tooth.new(side: "center") }.to raise_error(ArgumentError)
    end
  end

  describe "#practice_id" do
    it "delegates to jaw" do
      t = tooth(jaw: maxilla, side: :right, number: 1)
      expect(t.practice_id).to eq(dental_model.practice_id)
    end
  end

  describe "#universal_number" do
    context "maxilla (upper jaw)" do
      context "right side" do
        it "maps number 1 to universal 8" do
          expect(tooth(jaw: maxilla, side: :right, number: 1).universal_number).to eq(8)
        end

        it "maps number 8 to universal 1" do
          expect(tooth(jaw: maxilla, side: :right, number: 8).universal_number).to eq(1)
        end
      end

      context "left side" do
        it "maps number 1 to universal 9" do
          expect(tooth(jaw: maxilla, side: :left, number: 1).universal_number).to eq(9)
        end

        it "maps number 8 to universal 16" do
          expect(tooth(jaw: maxilla, side: :left, number: 8).universal_number).to eq(16)
        end
      end
    end

    context "mandible (lower jaw)" do
      context "left side" do
        it "maps number 1 to universal 24" do
          expect(tooth(jaw: mandible, side: :left, number: 1).universal_number).to eq(24)
        end

        it "maps number 8 to universal 17" do
          expect(tooth(jaw: mandible, side: :left, number: 8).universal_number).to eq(17)
        end
      end

      context "right side" do
        it "maps number 1 to universal 25" do
          expect(tooth(jaw: mandible, side: :right, number: 1).universal_number).to eq(25)
        end

        it "maps number 8 to universal 32" do
          expect(tooth(jaw: mandible, side: :right, number: 8).universal_number).to eq(32)
        end
      end
    end
  end
end
