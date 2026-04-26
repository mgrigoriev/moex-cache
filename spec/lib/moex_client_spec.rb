require "rails_helper"

RSpec.describe MoexClient do
  subject(:client) { described_class.new }

  describe "#fetch_stocks" do
    context "with valid data" do
      before { stub_request(:get, MoexClient::STOCKS_URL).to_return(body: "GAZP;124.24\nSBERP;326.03\nYDEX;4290\n") }

      it "returns parsed stocks" do
        expect(client.fetch_stocks).to eq([
          { secid: "GAZP", market_price: BigDecimal("124.24") },
          { secid: "SBERP", market_price: BigDecimal("326.03") },
          { secid: "YDEX", market_price: BigDecimal("4290") }
        ])
      end
    end

    context "when price is empty" do
      before { stub_request(:get, MoexClient::STOCKS_URL).to_return(body: "GAZP;124.24\nMGNZ;\n") }

      it "skips rows without price" do
        expect(client.fetch_stocks.map { |s| s[:secid] }).to eq([ "GAZP" ])
      end
    end

    context "when API returns error" do
      before { stub_request(:get, MoexClient::STOCKS_URL).to_return(status: 503) }

      it "raises an error" do
        expect { client.fetch_stocks }.to raise_error(RuntimeError, /503/)
      end
    end
  end

  describe "#fetch_funds" do
    before do
      stub_request(:get, MoexClient::FUNDS_URL).to_return(body: "TMOS;6.15\nFXUS;\n")
    end

    it "returns parsed funds and skips empty prices" do
      expect(client.fetch_funds).to eq([
        { secid: "TMOS", market_price: BigDecimal("6.15") }
      ])
    end
  end
end
