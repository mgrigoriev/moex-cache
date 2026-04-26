require "rails_helper"

RSpec.describe UpdateFundsJob, type: :job do
  it "calls UpdateFunds service" do
    service = instance_double(UpdateFunds, call: nil)
    allow(UpdateFunds).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
