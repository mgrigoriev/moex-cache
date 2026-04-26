require "csv"

class FundCsvSerializer
  HEADERS = %w[secid market_price].freeze

  def self.call(funds)
    CSV.generate do |csv|
      csv << HEADERS
      funds.each { |f| csv << [ f.secid, f.market_price ] }
    end
  end
end
