require "rails_helper"

RSpec.describe UpdateMoexbcJob, type: :job do
  it "calls UpdateMoexbc service" do
    service = instance_double(UpdateMoexbc, call: nil)
    allow(UpdateMoexbc).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
