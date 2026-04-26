require "rails_helper"

RSpec.describe UpdateStocksJob, type: :job do
  it "calls UpdateStocks service" do
    service = instance_double(UpdateStocks, call: nil)
    allow(UpdateStocks).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
