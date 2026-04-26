class UpdateFunds
  def call
    funds = MoexClient.new.fetch_funds
    Fund.upsert_all(funds, unique_by: :secid, update_only: [ :market_price ])
  end
end
