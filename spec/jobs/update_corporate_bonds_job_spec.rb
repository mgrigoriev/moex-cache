require "rails_helper"

RSpec.describe UpdateCorporateBondsJob, type: :job do
  it "calls UpdateCorporateBonds service" do
    service = instance_double(UpdateCorporateBonds, call: nil)
    allow(UpdateCorporateBonds).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
