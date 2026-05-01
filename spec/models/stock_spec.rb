require "rails_helper"

RSpec.describe Stock, type: :model do
  subject { Stock.new(secid: "GAZP", market_price: 124.24) }

  it { is_expected.to validate_presence_of(:secid) }
  it { is_expected.to validate_presence_of(:market_price) }
  it { is_expected.to validate_uniqueness_of(:secid) }

  describe ".in_portfolio" do
    it "returns only portfolio stocks" do
      portfolio = Stock.create!(secid: "SBER", market_price: 326, in_portfolio: true)
      Stock.create!(secid: "GAZP", market_price: 124, in_portfolio: false)

      expect(Stock.in_portfolio).to contain_exactly(portfolio)
    end
  end
end
