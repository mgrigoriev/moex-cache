FactoryBot.define do
  factory :fund do
    sequence(:secid) { |n| "FUND#{n}" }
    market_price { BigDecimal("100.00") }
  end
end
