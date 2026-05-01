require "rails_helper"

RSpec.describe ImoexComponent, type: :model do
  subject { ImoexComponent.new(ticker: "GAZP", weight: 0.0956) }

  it { is_expected.to validate_presence_of(:ticker) }
  it { is_expected.to validate_presence_of(:weight) }
  it { is_expected.to validate_uniqueness_of(:ticker) }
end
