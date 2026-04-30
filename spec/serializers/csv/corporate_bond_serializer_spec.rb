require "rails_helper"

RSpec.describe Csv::CorporateBondSerializer do
  describe ".call" do
    it "generates CSV with header and rows in the expected order (secid duplicated)" do
      bonds = [
        build(:corporate_bond,
          secid: "RU000A0JX0J2",
          short_name: "Газпром БО-1",
          market_price: BigDecimal("98.50"),
          ytm: BigDecimal("12.50"),
          duration: 365,
          coupon_percent: BigDecimal("10.0"),
          coupon_period: 182,
          maturity_date: "2026-06-01",
          face_value: BigDecimal("1000"),
          accrued_interest: BigDecimal("15.00"))
      ]

      expect(described_class.call(bonds)).to eq(<<~CSV)
        secid,market_price,ytm,duration,secid,short_name,coupon_percent,coupon_period,maturity_date,face_value,accrued_interest
        RU000A0JX0J2,98.5,12.5,365,RU000A0JX0J2,Газпром БО-1,10.0,182,2026-06-01,1000.0,15.0
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq(
        "secid,market_price,ytm,duration,secid,short_name,coupon_percent,coupon_period,maturity_date,face_value,accrued_interest\n"
      )
    end
  end
end
