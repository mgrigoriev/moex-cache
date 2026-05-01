module Csv
  class StockSerializer < BaseSerializer
    HEADERS = %w[
      secid
      market_price
      dividend_forecast
    ].freeze
  end
end
