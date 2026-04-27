class Ofz < ApplicationRecord
  self.table_name = "ofz"

  validates :secid, presence: true, uniqueness: true
end
