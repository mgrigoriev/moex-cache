FactoryBot.define do
  factory :imoex_component do
    sequence(:ticker) { |n| "TICKER#{n}" }
    weight { BigDecimal("0.015") }
  end
end
