require "rails_helper"

RSpec.describe Csv::FundSerializer do
  describe ".call" do
    it "generates CSV with header and rows" do
      funds = [ build(:fund, secid: "TMOS", market_price: BigDecimal("6.15")) ]

      expect(described_class.call(funds)).to eq(<<~CSV)
        secid,market_price
        TMOS,6.15
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq("secid,market_price\n")
    end
  end
end
