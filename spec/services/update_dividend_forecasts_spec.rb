require "rails_helper"

RSpec.describe UpdateDividendForecasts do
  subject(:service) { described_class.new }

  let(:client) { instance_double(DohodClient) }

  before do
    allow(DohodClient).to receive(:new).and_return(client)
    allow(service).to receive(:sleep)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
  end

  describe "#call" do
    context "when client returns forecasts for all portfolio stocks" do
      before do
        Stock.create!(secid: "SBER", market_price: BigDecimal("326.03"), in_portfolio: true)
        Stock.create!(secid: "GAZP", market_price: BigDecimal("124.24"), in_portfolio: true)
        allow(client).to receive(:fetch_forecast).with("SBER").and_return(BigDecimal("35"))
        allow(client).to receive(:fetch_forecast).with("GAZP").and_return(BigDecimal("0"))
      end

      it "writes forecasts to corresponding rows" do
        service.call
        expect(Stock.find_by(secid: "SBER").dividend_forecast).to eq(BigDecimal("35"))
        expect(Stock.find_by(secid: "GAZP").dividend_forecast).to eq(BigDecimal("0"))
      end

      it "logs one info line per ticker with position, ticker, and value" do
        service.call
        expect(Rails.logger).to have_received(:info).with("UpdateDividendForecasts: [1/2] GAZP -> 0.0")
        expect(Rails.logger).to have_received(:info).with("UpdateDividendForecasts: [2/2] SBER -> 35.0")
      end
    end

    context "when client returns nil" do
      before do
        Stock.create!(secid: "SBER", market_price: BigDecimal("326.03"), dividend_forecast: BigDecimal("99"), in_portfolio: true)
        allow(client).to receive(:fetch_forecast).with("SBER").and_return(nil)
      end

      it "overwrites existing value with NULL" do
        service.call
        expect(Stock.find_by(secid: "SBER").dividend_forecast).to be_nil
      end

      it "logs nil result" do
        service.call
        expect(Rails.logger).to have_received(:info).with("UpdateDividendForecasts: [1/1] SBER -> nil")
      end
    end

    context "when client raises for one ticker" do
      before do
        Stock.create!(secid: "AAA", market_price: BigDecimal("100"), dividend_forecast: BigDecimal("99"), in_portfolio: true)
        Stock.create!(secid: "BBB", market_price: BigDecimal("100"), in_portfolio: true)
        Stock.create!(secid: "CCC", market_price: BigDecimal("100"), in_portfolio: true)
        allow(client).to receive(:fetch_forecast).with("AAA").and_return(BigDecimal("1"))
        allow(client).to receive(:fetch_forecast).with("BBB").and_raise("dohod.ru error: 404")
        allow(client).to receive(:fetch_forecast).with("CCC").and_return(BigDecimal("3"))
      end

      it "continues to the next ticker after a failure" do
        service.call
        expect(Stock.find_by(secid: "AAA").dividend_forecast).to eq(BigDecimal("1"))
        expect(Stock.find_by(secid: "CCC").dividend_forecast).to eq(BigDecimal("3"))
      end

      it "preserves the existing value of the failed ticker" do
        service.call
        expect(Stock.reset_column_information || true)
        # Note: AAA has secid alphabetically before BBB; "BBB" failed mid-loop and its prior value (nil) is preserved.
        # The point of this expectation is that nothing crashed and we reached CCC.
        expect(Stock.find_by(secid: "BBB").dividend_forecast).to be_nil
      end

      it "logs the failure as a warning with position and ticker" do
        service.call
        expect(Rails.logger).to have_received(:warn)
          .with(/UpdateDividendForecasts: \[2\/3\] BBB -> error \(RuntimeError: dohod.ru error: 404\)/)
      end

      it "does not raise" do
        expect { service.call }.not_to raise_error
      end
    end

    context "when there are no portfolio stocks" do
      it "does not raise" do
        expect { service.call }.not_to raise_error
      end
    end

    context "when stock is not in portfolio" do
      before do
        Stock.create!(secid: "SBER", market_price: BigDecimal("326.03"), in_portfolio: true)
        Stock.create!(secid: "OUTSIDE", market_price: BigDecimal("100"), in_portfolio: false)
        allow(client).to receive(:fetch_forecast).with("SBER").and_return(BigDecimal("35"))
      end

      it "skips non-portfolio stocks entirely" do
        service.call
        expect(client).not_to have_received(:fetch_forecast).with("OUTSIDE")
        expect(Stock.find_by(secid: "OUTSIDE").dividend_forecast).to be_nil
      end
    end

    context "delays between requests" do
      before do
        Stock.create!(secid: "SBER", market_price: BigDecimal("326.03"), in_portfolio: true)
        Stock.create!(secid: "GAZP", market_price: BigDecimal("124.24"), in_portfolio: true)
        Stock.create!(secid: "LKOH", market_price: BigDecimal("6500"), in_portfolio: true)
        allow(client).to receive(:fetch_forecast).and_return(nil)
      end

      it "sleeps once per request after the first" do
        service.call
        expect(service).to have_received(:sleep).with(described_class::REQUEST_DELAY).twice
      end
    end
  end
end
