FactoryBot.define do
  factory :moexbc_component do
    sequence(:ticker) { |n| "TICKER#{n}" }
    weight { BigDecimal("0.05") }
  end
end
