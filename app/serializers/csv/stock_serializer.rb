module Csv
  class StockSerializer < BaseSerializer
    HEADERS = %w[
      secid
      market_price
    ].freeze
  end
end
