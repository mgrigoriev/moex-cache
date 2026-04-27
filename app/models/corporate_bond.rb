class CorporateBond < ApplicationRecord
  validates :secid, presence: true, uniqueness: true
end
