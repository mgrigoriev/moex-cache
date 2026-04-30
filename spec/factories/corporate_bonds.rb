FactoryBot.define do
  factory :corporate_bond do
    sequence(:secid) { |n| "RU000A0JX#{n}" }
    short_name { "Bond #{secid}" }
    market_price { BigDecimal("98.50") }
    ytm { BigDecimal("12.50") }
    duration { 365 }
    coupon_percent { BigDecimal("10.00") }
    coupon_period { 182 }
    maturity_date { "2026-06-01" }
    face_value { BigDecimal("1000") }
    accrued_interest { BigDecimal("15.00") }
  end
end
