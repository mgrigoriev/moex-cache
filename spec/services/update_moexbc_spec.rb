require "rails_helper"

RSpec.describe UpdateMoexbc do
  subject(:service) { described_class.new }

  let(:client) { instance_double(MoexClient) }

  before do
    allow(MoexClient).to receive(:new).and_return(client)
    allow(client).to receive(:fetch_moexbc).and_return(components)
  end

  describe "#call" do
    context "when there are no existing components" do
      let(:components) do
        [
          { ticker: "LKOH", weight: BigDecimal("0.1649") },
          { ticker: "SBER", weight: BigDecimal("0.159") }
        ]
      end

      it "inserts all components" do
        expect { service.call }.to change(MoexbcComponent, :count).by(2)
      end
    end

    context "when components already exist" do
      let(:components) { [ { ticker: "SBER", weight: BigDecimal("0.16") } ] }

      before do
        MoexbcComponent.create!(ticker: "LKOH", weight: BigDecimal("0.1649"))
        MoexbcComponent.create!(ticker: "SBER", weight: BigDecimal("0.159"))
      end

      it "replaces existing set with the fresh snapshot" do
        service.call
        expect(MoexbcComponent.pluck(:ticker)).to contain_exactly("SBER")
        expect(MoexbcComponent.find_by(ticker: "SBER").weight).to eq(BigDecimal("0.16"))
      end
    end

    context "when fetch returns empty" do
      let(:components) { [] }

      before { MoexbcComponent.create!(ticker: "LKOH", weight: BigDecimal("0.1649")) }

      it "does not wipe existing data" do
        expect { service.call }.not_to change(MoexbcComponent, :count)
      end
    end
  end
end
