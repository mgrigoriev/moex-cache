require "net/http"

class MoexClient
  STOCKS_URL = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.csv" \
               "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE"

  def fetch_stocks
    fetch(STOCKS_URL).filter_map do |line|
      secid, price = line.chomp.split(";")
      next if secid.blank? || price.blank?

      { secid: secid, market_price: BigDecimal(price) }
    end
  end

  private

  def fetch(url)
    response = Net::HTTP.get_response(URI(url))
    raise "MOEX API error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body.each_line
  end
end
