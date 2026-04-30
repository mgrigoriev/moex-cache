require "rails_helper"

RSpec.describe Csv::StockSerializer do
  describe ".call" do
    it "generates CSV with header and rows" do
      stocks = [
        build(:stock, secid: "GAZP", market_price: BigDecimal("124.24")),
        build(:stock, secid: "SBERP", market_price: BigDecimal("326.03"))
      ]

      expect(described_class.call(stocks)).to eq(<<~CSV)
        secid,market_price
        GAZP,124.24
        SBERP,326.03
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq("secid,market_price\n")
    end
  end
end
