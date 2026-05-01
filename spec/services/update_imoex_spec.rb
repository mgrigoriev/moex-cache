require "rails_helper"

RSpec.describe UpdateImoex do
  subject(:service) { described_class.new }

  let(:client) { instance_double(MoexClient) }

  before do
    allow(MoexClient).to receive(:new).and_return(client)
    allow(client).to receive(:fetch_imoex).and_return(components)
  end

  describe "#call" do
    context "when there are no existing components" do
      let(:components) do
        [
          { ticker: "LKOH", weight: BigDecimal("0.1652") },
          { ticker: "GAZP", weight: BigDecimal("0.0956") }
        ]
      end

      it "inserts all components" do
        expect { service.call }.to change(ImoexComponent, :count).by(2)
      end
    end

    context "when components already exist" do
      let(:components) { [ { ticker: "LKOH", weight: BigDecimal("0.17") } ] }

      before do
        ImoexComponent.create!(ticker: "GAZP", weight: BigDecimal("0.0956"))
        ImoexComponent.create!(ticker: "LKOH", weight: BigDecimal("0.1652"))
      end

      it "replaces existing set with the fresh snapshot" do
        service.call
        expect(ImoexComponent.pluck(:ticker)).to contain_exactly("LKOH")
        expect(ImoexComponent.find_by(ticker: "LKOH").weight).to eq(BigDecimal("0.17"))
      end
    end

    context "when fetch returns empty" do
      let(:components) { [] }

      before { ImoexComponent.create!(ticker: "GAZP", weight: BigDecimal("0.0956")) }

      it "does not wipe existing data" do
        expect { service.call }.not_to change(ImoexComponent, :count)
      end
    end
  end
end
