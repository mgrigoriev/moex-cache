require "rails_helper"

RSpec.describe UpdateDividendForecastsJob, type: :job do
  it "calls UpdateDividendForecasts service" do
    service = instance_double(UpdateDividendForecasts, call: nil)
    allow(UpdateDividendForecasts).to receive(:new).and_return(service)

    described_class.perform_now

    expect(service).to have_received(:call)
  end
end
