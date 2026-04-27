require "rails_helper"

RSpec.describe UpdateCorporateBonds do
  subject(:service) { described_class.new }

  let(:client) { instance_double(MoexClient) }
  let(:bond_attrs) do
    {
      secid: "RU000A0JX0J2",
      short_name: "Газпром БО-1",
      market_price: BigDecimal("98.50"),
      ytm: BigDecimal("12.50"),
      duration: 365,
      coupon_percent: BigDecimal("10.0"),
      coupon_period: 182,
      maturity_date: "2026-06-01",
      face_value: BigDecimal("1000"),
      accrued_interest: BigDecimal("15.00")
    }
  end

  before do
    allow(MoexClient).to receive(:new).and_return(client)
    allow(client).to receive(:fetch_corporate_bonds).and_return(bonds)
  end

  describe "#call" do
    context "when there are no existing records" do
      let(:bonds) { [ bond_attrs ] }

      it "inserts all bonds" do
        expect { service.call }.to change(CorporateBond, :count).by(1)
      end
    end

    context "when bond already exists" do
      let(:bonds) { [ bond_attrs.merge(market_price: BigDecimal("99.00")) ] }

      before { CorporateBond.create!(secid: "RU000A0JX0J2", market_price: BigDecimal("98.50")) }

      it "updates the price" do
        service.call
        expect(CorporateBond.find_by(secid: "RU000A0JX0J2").market_price).to eq(BigDecimal("99.00"))
      end

      it "does not create a duplicate" do
        expect { service.call }.not_to change(CorporateBond, :count)
      end
    end
  end
end
