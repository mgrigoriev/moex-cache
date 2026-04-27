require "rails_helper"

RSpec.describe UpdateOfz do
  subject(:service) { described_class.new }

  let(:client) { instance_double(MoexClient) }
  let(:bond_attrs) do
    {
      secid: "SU26207RMFS9",
      short_name: "ОФЗ 26207",
      market_price: BigDecimal("96.75"),
      ytm: BigDecimal("13.08"),
      duration: 274,
      coupon_percent: BigDecimal("8.15"),
      coupon_period: 182,
      maturity_date: "2027-02-03",
      face_value: BigDecimal("1000"),
      accrued_interest: BigDecimal("18.53")
    }
  end

  before do
    allow(MoexClient).to receive(:new).and_return(client)
    allow(client).to receive(:fetch_ofz).and_return(bonds)
  end

  describe "#call" do
    context "when there are no existing records" do
      let(:bonds) { [ bond_attrs ] }

      it "inserts all bonds" do
        expect { service.call }.to change(Ofz, :count).by(1)
      end
    end

    context "when bond already exists" do
      let(:bonds) { [ bond_attrs.merge(market_price: BigDecimal("100.00")) ] }

      before { Ofz.create!(secid: "SU26207RMFS9", market_price: BigDecimal("96.75")) }

      it "updates the price" do
        service.call
        expect(Ofz.find_by(secid: "SU26207RMFS9").market_price).to eq(BigDecimal("100.00"))
      end

      it "does not create a duplicate" do
        expect { service.call }.not_to change(Ofz, :count)
      end
    end
  end
end
