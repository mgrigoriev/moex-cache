require "net/http"

class MoexClient
  STOCKS_URL = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQBR/securities.csv" \
               "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE"

  FUNDS_URL = "https://iss.moex.com/iss/engines/stock/markets/shares/boards/TQTF/securities.csv" \
              "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE"

  OFZ_MARKETDATA_URL = "https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQOB/securities.csv" \
                       "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE,YIELD,DURATION"

  OFZ_SECURITIES_URL = "https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQOB/securities.csv" \
                       "?iss.meta=off&iss.only=securities&securities.columns=SECID,SHORTNAME,COUPONPERCENT,COUPONPERIOD,MATDATE,FACEVALUE,ACCRUEDINT"

  CORP_MARKETDATA_URL = "https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQCB/securities.csv" \
                        "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,MARKETPRICE,YIELD,DURATION"

  CORP_SECURITIES_URL = "https://iss.moex.com/iss/engines/stock/markets/bonds/boards/TQCB/securities.csv" \
                        "?iss.meta=off&iss.only=securities&securities.columns=SECID,SHORTNAME,COUPONPERCENT,COUPONPERIOD,MATDATE,FACEVALUE,ACCRUEDINT"

  CURRENCIES_URL = "https://iss.moex.com/iss/engines/currency/markets/selt/boards/CETS/securities.csv" \
                   "?iss.meta=off&iss.only=marketdata&marketdata.columns=SECID,LAST,MARKETPRICE" \
                   "&securities=#{Currency::CODE_BY_SECID.keys.join(',')}"

  def fetch_stocks
    parse(fetch(STOCKS_URL))
  end

  def fetch_funds
    parse(fetch(FUNDS_URL))
  end

  def fetch_ofz
    fetch_bonds(OFZ_MARKETDATA_URL, OFZ_SECURITIES_URL)
  end

  def fetch_corporate_bonds
    fetch_bonds(CORP_MARKETDATA_URL, CORP_SECURITIES_URL)
  end

  def fetch_currencies
    fetch(CURRENCIES_URL).filter_map do |line|
      secid, last, market_price = line.chomp.split(";")
      price = last.presence || market_price.presence
      next if secid.blank? || price.blank?

      { secid: secid, market_price: BigDecimal(price) }
    end
  end

  private

  def parse(lines)
    lines.filter_map do |line|
      secid, price = line.chomp.split(";")
      next if secid.blank? || price.blank?

      { secid: secid, market_price: BigDecimal(price) }
    end
  end

  def fetch_bonds(marketdata_url, securities_url)
    marketdata = parse_bond_marketdata(fetch(marketdata_url))
    securities = parse_bond_securities(fetch(securities_url))

    securities.filter_map do |attrs|
      market = marketdata[attrs[:secid]]
      next if market.nil? || market[:market_price].blank?

      attrs.merge(market)
    end
  end

  def parse_bond_marketdata(lines)
    lines.each_with_object({}) do |line, hash|
      secid, price, ytm, duration = line.chomp.split(";")
      next if secid.blank?

      hash[secid] = {
        market_price: price.present? ? BigDecimal(price) : nil,
        ytm:          ytm.present? ? BigDecimal(ytm) : nil,
        duration:     duration.present? ? duration.to_i : nil
      }
    end
  end

  def parse_bond_securities(lines)
    lines.filter_map do |line|
      secid, short_name, coupon_percent, coupon_period, maturity_date, face_value, accrued_interest = line.chomp.split(";")
      next if secid.blank?

      {
        secid:             secid,
        short_name:        short_name,
        coupon_percent:    coupon_percent.present? ? BigDecimal(coupon_percent) : nil,
        coupon_period:     coupon_period.present? ? coupon_period.to_i : nil,
        maturity_date:     maturity_date.presence,
        face_value:        face_value.present? ? BigDecimal(face_value) : nil,
        accrued_interest:  accrued_interest.present? ? BigDecimal(accrued_interest) : nil
      }
    end
  end

  def fetch(url)
    response = Net::HTTP.get_response(URI(url))
    raise "MOEX API error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body.force_encoding("Windows-1251").encode("UTF-8").each_line
  end
end
