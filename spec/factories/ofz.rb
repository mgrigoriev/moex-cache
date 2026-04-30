FactoryBot.define do
  factory :ofz do
    sequence(:secid) { |n| "SU#{26000 + n}RMFS9" }
    short_name { "ОФЗ #{secid}" }
    market_price { BigDecimal("96.75") }
    ytm { BigDecimal("13.08") }
    duration { 274 }
    coupon_percent { BigDecimal("8.15") }
    coupon_period { 182 }
    maturity_date { "2027-02-03" }
    face_value { BigDecimal("1000") }
    accrued_interest { BigDecimal("18.53") }
  end
end
