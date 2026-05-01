class UpdateDividendForecasts
  REQUEST_DELAY = 1.0

  def call
    client = DohodClient.new
    secids = Stock.in_portfolio.order(:secid).pluck(:secid)
    total = secids.size

    secids.each_with_index do |secid, index|
      sleep(REQUEST_DELAY) unless index.zero?

      position = "[#{index + 1}/#{total}]"

      begin
        forecast = client.fetch_forecast(secid)
        Stock.where(secid: secid).update_all(dividend_forecast: forecast, updated_at: Time.current)
        Rails.logger.info("UpdateDividendForecasts: #{position} #{secid} -> #{forecast || 'nil'}")
      rescue StandardError => e
        Rails.logger.warn("UpdateDividendForecasts: #{position} #{secid} -> error (#{e.class}: #{e.message})")
      end
    end
  end
end
