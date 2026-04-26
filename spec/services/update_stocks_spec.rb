require "rails_helper"

RSpec.describe UpdateStocks do
  subject(:service) { described_class.new }

  let(:client) { instance_double(MoexClient) }

  before do
    allow(MoexClient).to receive(:new).and_return(client)
    allow(client).to receive(:fetch_stocks).and_return(stocks)
  end

  describe "#call" do
    context "when there are no existing stocks" do
      let(:stocks) do
        [
          { secid: "GAZP", market_price: BigDecimal("124.24") },
          { secid: "SBERP", market_price: BigDecimal("326.03") }
        ]
      end

      it "inserts all stocks" do
        expect { service.call }.to change(Stock, :count).by(2)
      end
    end

    context "when stock already exists" do
      let(:stocks) { [ { secid: "GAZP", market_price: BigDecimal("200.00") } ] }

      before { Stock.create!(secid: "GAZP", market_price: BigDecimal("124.24")) }

      it "updates the price" do
        service.call
        expect(Stock.find_by(secid: "GAZP").market_price).to eq(BigDecimal("200.00"))
      end

      it "does not create a duplicate" do
        expect { service.call }.not_to change(Stock, :count)
      end
    end
  end
end
