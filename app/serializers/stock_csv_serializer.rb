require "csv"

class StockCsvSerializer
  HEADERS = %w[secid market_price].freeze

  def self.call(stocks)
    CSV.generate do |csv|
      csv << HEADERS
      stocks.each { |s| csv << [ s.secid, s.market_price ] }
    end
  end
end
