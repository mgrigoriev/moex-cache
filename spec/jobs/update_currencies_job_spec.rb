require "rails_helper"

RSpec.describe UpdateCurrenciesJob, type: :job do
  it "calls UpdateCurrencies service" do
    service = instance_double(UpdateCurrencies, call: nil)
    allow(UpdateCurrencies).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
