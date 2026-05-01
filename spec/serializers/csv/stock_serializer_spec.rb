require "rails_helper"

RSpec.describe Csv::StockSerializer do
  describe ".call" do
    it "generates CSV with header and rows" do
      stocks = [
        build(:stock, secid: "GAZP", market_price: BigDecimal("124.24"), dividend_forecast: nil),
        build(:stock, secid: "SBER", market_price: BigDecimal("326.03"), dividend_forecast: BigDecimal("35")),
        build(:stock, secid: "MTSS", market_price: BigDecimal("210.5"), dividend_forecast: BigDecimal("0"))
      ]

      expect(described_class.call(stocks)).to eq(<<~CSV)
        secid,market_price,dividend_forecast
        GAZP,124.24,
        SBER,326.03,35.0
        MTSS,210.5,0.0
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq("secid,market_price,dividend_forecast\n")
    end
  end
end
