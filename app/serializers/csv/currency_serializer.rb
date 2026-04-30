module Csv
  class CurrencySerializer < BaseSerializer
    HEADERS = %w[
      code
      market_price
    ].freeze
  end
end
