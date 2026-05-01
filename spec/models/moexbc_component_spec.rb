require "rails_helper"

RSpec.describe MoexbcComponent, type: :model do
  subject { MoexbcComponent.new(ticker: "LKOH", weight: 0.1649) }

  it { is_expected.to validate_presence_of(:ticker) }
  it { is_expected.to validate_presence_of(:weight) }
  it { is_expected.to validate_uniqueness_of(:ticker) }
end
