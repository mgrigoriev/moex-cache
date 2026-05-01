class ImoexComponent < ApplicationRecord
  validates :ticker, presence: true, uniqueness: true
  validates :weight, presence: true
end
