module Csv
  class OfzSerializer < BaseSerializer
    HEADERS = %w[
      secid
      market_price
      ytm
      duration
      secid
      short_name
      coupon_percent
      coupon_period
      maturity_date
      face_value
      accrued_interest
    ].freeze
  end
end
