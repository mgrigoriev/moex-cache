class Fund < ApplicationRecord
  validates :secid, presence: true, uniqueness: true
  validates :market_price, presence: true
end
