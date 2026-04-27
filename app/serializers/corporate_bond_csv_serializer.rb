require "csv"

class CorporateBondCsvSerializer
  HEADERS = %w[secid market_price ytm duration secid short_name coupon_percent coupon_period maturity_date face_value accrued_interest].freeze

  def self.call(bonds)
    CSV.generate do |csv|
      csv << HEADERS
      bonds.each do |b|
        csv << [
          b.secid, b.market_price, b.ytm, b.duration,
          b.secid, b.short_name, b.coupon_percent, b.coupon_period,
          b.maturity_date, b.face_value, b.accrued_interest
        ]
      end
    end
  end
end
