require "rails_helper"

RSpec.describe Csv::MoexbcComponentSerializer do
  describe ".call" do
    it "generates CSV with header and rows" do
      components = [
        build(:moexbc_component, ticker: "LKOH", weight: BigDecimal("0.1649")),
        build(:moexbc_component, ticker: "SBER", weight: BigDecimal("0.159"))
      ]

      expect(described_class.call(components)).to eq(<<~CSV)
        ticker,weight
        LKOH,0.1649
        SBER,0.159
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq("ticker,weight\n")
    end
  end
end
