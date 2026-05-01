class Currency < ApplicationRecord
  TICKERS = {
    "USD000UTSTOM" => { code: "USD", lot: 1 },
    "EUR_RUB__TOM" => { code: "EUR", lot: 1 },
    "CNYRUB_TOM"   => { code: "CNY", lot: 1 },
    "AMDRUB_TOM"   => { code: "AMD", lot: 100 }
  }.freeze

  validates :secid, presence: true, uniqueness: true
  validates :market_price, presence: true

  def code
    TICKERS.dig(secid, :code)
  end
end
