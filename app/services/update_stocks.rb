class UpdateStocks
  def call
    stocks = MoexClient.new.fetch_stocks
    Stock.upsert_all(stocks, unique_by: :secid, update_only: [ :market_price ])
    Rails.logger.info("UpdateStocks: upserted #{stocks.size} records")
  end
end
