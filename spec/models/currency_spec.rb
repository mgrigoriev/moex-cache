require "rails_helper"

RSpec.describe Currency, type: :model do
  subject { build(:currency) }

  it { is_expected.to validate_presence_of(:secid) }
  it { is_expected.to validate_presence_of(:market_price) }
  it { is_expected.to validate_uniqueness_of(:secid) }
end
