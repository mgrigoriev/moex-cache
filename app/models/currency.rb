class Currency < ApplicationRecord
  CODE_BY_SECID = {
    "USD000UTSTOM" => "USD",
    "EUR_RUB__TOM" => "EUR",
    "CNYRUB_TOM"   => "CNY",
    "AMDRUB_TOM"   => "AMD"
  }.freeze

  validates :secid, presence: true, uniqueness: true
  validates :market_price, presence: true

  def code
    CODE_BY_SECID[secid]
  end
end
