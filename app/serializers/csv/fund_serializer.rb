module Csv
  class FundSerializer < BaseSerializer
    HEADERS = %w[
      secid
      market_price
    ].freeze
  end
end
