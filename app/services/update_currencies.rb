class UpdateCurrencies
  def call
    currencies = MoexClient.new.fetch_currencies
    Currency.upsert_all(currencies, unique_by: :secid, update_only: [ :market_price ])
    Rails.logger.info("UpdateCurrencies: upserted #{currencies.size} records")
  end
end
