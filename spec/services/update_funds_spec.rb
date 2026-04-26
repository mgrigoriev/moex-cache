require "rails_helper"

RSpec.describe UpdateFunds do
  subject(:service) { described_class.new }

  let(:client) { instance_double(MoexClient) }

  before do
    allow(MoexClient).to receive(:new).and_return(client)
    allow(client).to receive(:fetch_funds).and_return(funds)
  end

  describe "#call" do
    context "when there are no existing funds" do
      let(:funds) do
        [
          { secid: "TMOS", market_price: BigDecimal("6.15") },
          { secid: "FXUS", market_price: BigDecimal("101.50") }
        ]
      end

      it "inserts all funds" do
        expect { service.call }.to change(Fund, :count).by(2)
      end
    end

    context "when fund already exists" do
      let(:funds) { [ { secid: "TMOS", market_price: BigDecimal("7.00") } ] }

      before { Fund.create!(secid: "TMOS", market_price: BigDecimal("6.15")) }

      it "updates the price" do
        service.call
        expect(Fund.find_by(secid: "TMOS").market_price).to eq(BigDecimal("7.00"))
      end

      it "does not create a duplicate" do
        expect { service.call }.not_to change(Fund, :count)
      end
    end
  end
end
