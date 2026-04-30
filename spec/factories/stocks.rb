FactoryBot.define do
  factory :stock do
    sequence(:secid) { |n| "TICKER#{n}" }
    market_price { BigDecimal("100.00") }
  end
end
