require "rails_helper"

RSpec.describe Fund, type: :model do
  subject { Fund.new(secid: "TMOS", market_price: 6.15) }

  it { is_expected.to validate_presence_of(:secid) }
  it { is_expected.to validate_presence_of(:market_price) }
  it { is_expected.to validate_uniqueness_of(:secid) }
end
