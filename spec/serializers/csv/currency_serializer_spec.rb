require "rails_helper"

RSpec.describe Csv::CurrencySerializer do
  describe ".call" do
    it "generates CSV with currency codes instead of full tickers" do
      currencies = [ build(:currency, secid: "USD000UTSTOM", market_price: BigDecimal("74.98")) ]

      expect(described_class.call(currencies)).to eq(<<~CSV)
        code,market_price
        USD,74.98
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq("code,market_price\n")
    end
  end
end
