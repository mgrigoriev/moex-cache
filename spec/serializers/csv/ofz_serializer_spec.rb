require "rails_helper"

RSpec.describe Csv::OfzSerializer do
  describe ".call" do
    it "generates CSV with header and rows in the expected order (secid duplicated)" do
      bonds = [
        build(:ofz,
          secid: "SU26207RMFS9",
          short_name: "ОФЗ 26207",
          market_price: BigDecimal("96.75"),
          ytm: BigDecimal("13.08"),
          duration: 274,
          coupon_percent: BigDecimal("8.15"),
          coupon_period: 182,
          maturity_date: "2027-02-03",
          face_value: BigDecimal("1000"),
          accrued_interest: BigDecimal("18.53"))
      ]

      expect(described_class.call(bonds)).to eq(<<~CSV)
        secid,market_price,ytm,duration,secid,short_name,coupon_percent,coupon_period,maturity_date,face_value,accrued_interest
        SU26207RMFS9,96.75,13.08,274,SU26207RMFS9,ОФЗ 26207,8.15,182,2027-02-03,1000.0,18.53
      CSV
    end

    it "returns only header for empty collection" do
      expect(described_class.call([])).to eq(
        "secid,market_price,ytm,duration,secid,short_name,coupon_percent,coupon_period,maturity_date,face_value,accrued_interest\n"
      )
    end
  end
end
