class UpdateOfz
  def call
    bonds = MoexClient.new.fetch_ofz
    Ofz.upsert_all(bonds, unique_by: :secid, update_only: %i[
      short_name market_price ytm duration
      coupon_percent coupon_period maturity_date face_value accrued_interest
    ])
    Rails.logger.info("UpdateOfz: upserted #{bonds.size} records")
  end
end
