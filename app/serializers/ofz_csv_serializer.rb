require "csv"

class OfzCsvSerializer
  HEADERS = %w[secid market_price ytm duration secid short_name coupon_percent coupon_period maturity_date face_value accrued_interest].freeze

  def self.call(ofz)
    CSV.generate do |csv|
      csv << HEADERS
      ofz.each do |o|
        csv << [
          o.secid, o.market_price, o.ytm, o.duration,
          o.secid, o.short_name, o.coupon_percent, o.coupon_period,
          o.maturity_date, o.face_value, o.accrued_interest
        ]
      end
    end
  end
end
