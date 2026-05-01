class Stock < ApplicationRecord
  validates :secid, presence: true, uniqueness: true
  validates :market_price, presence: true

  scope :in_portfolio, -> { where(in_portfolio: true) }
end
