require "rails_helper"

RSpec.describe Csv::ImoexComponentSerializer do
  describe ".call" do
    it "generates CSV with header and rows" do
      components = [
        build(:imoex_component, ticker: "LKOH", weight: BigDecimal("0.1652")),
        build(:imoex_component, ticker: "GAZP", weight: BigDecimal("0.0956"))
      ]

      expect(described_class.call(components)).to eq(<<~CSV)
        ticker,weight
        LKOH,0.1652
        GAZP,0.0956
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq("ticker,weight\n")
    end
  end
end
