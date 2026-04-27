require "rails_helper"

RSpec.describe UpdateOfzJob, type: :job do
  it "calls UpdateOfz service" do
    service = instance_double(UpdateOfz, call: nil)
    allow(UpdateOfz).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
