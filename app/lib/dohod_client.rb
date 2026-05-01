require "net/http"

class DohodClient
  BASE_URL = "https://www.dohod.ru/ik/analytics/dividend".freeze

  def fetch_forecast(ticker)
    response = Net::HTTP.get_response(URI("#{BASE_URL}/#{ticker.downcase}"))
    raise "dohod.ru error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    parse(response.body)
  end

  private

  def parse(html)
    cell = Nokogiri::HTML(html).at_css("tr.forecast td:nth-child(2)")
    return nil if cell.nil?

    text = cell.text.strip
    return nil if text.blank? || text == "-"

    BigDecimal(text)
  rescue ArgumentError
    nil
  end
end
