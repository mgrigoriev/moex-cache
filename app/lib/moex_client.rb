require "net/http"

class MoexClient
  STOCKS_URL = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.csv" \
               "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE"

  FUNDS_URL = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQTF/securities.csv" \
              "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE"

  def fetch_stocks
    parse(fetch(STOCKS_URL))
  end

  def fetch_funds
    parse(fetch(FUNDS_URL))
  end

  private

  def parse(lines)
    lines.filter_map do |line|
      secid, price = line.chomp.split(";")
      next if secid.blank? || price.blank?

      { secid: secid, market_price: BigDecimal(price) }
    end
  end

  def fetch(url)
    response = Net::HTTP.get_response(URI(url))
    raise "MOEX API error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body.each_line
  end
end
