require "rails_helper"

RSpec.describe UpdateImoexJob, type: :job do
  it "calls UpdateImoex service" do
    service = instance_double(UpdateImoex, call: nil)
    allow(UpdateImoex).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
