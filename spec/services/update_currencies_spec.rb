require "rails_helper"

RSpec.describe UpdateCurrencies do
  subject(:service) { described_class.new }

  let(:client) { instance_double(MoexClient) }

  before do
    allow(MoexClient).to receive(:new).and_return(client)
    allow(client).to receive(:fetch_currencies).and_return(currencies)
  end

  describe "#call" do
    context "when there are no existing currencies" do
      let(:currencies) do
        [
          { secid: "USD000UTSTOM", market_price: BigDecimal("74.98") },
          { secid: "CNYRUB_TOM", market_price: BigDecimal("10.97") }
        ]
      end

      it "inserts all currencies" do
        expect { service.call }.to change(Currency, :count).by(2)
      end
    end

    context "when currency already exists" do
      let(:currencies) { [ { secid: "USD000UTSTOM", market_price: BigDecimal("80.00") } ] }

      before { Currency.create!(secid: "USD000UTSTOM", market_price: BigDecimal("74.98")) }

      it "updates the price" do
        service.call
        expect(Currency.find_by(secid: "USD000UTSTOM").market_price).to eq(BigDecimal("80.00"))
      end

      it "does not create a duplicate" do
        expect { service.call }.not_to change(Currency, :count)
      end
    end
  end
end
