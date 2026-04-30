FactoryBot.define do
  factory :currency do
    sequence(:secid) { |n| "CUR#{n}" }
    market_price { BigDecimal("100.00") }
  end
end
