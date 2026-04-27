class UpdateCorporateBonds
  def call
    bonds = MoexClient.new.fetch_corporate_bonds
    CorporateBond.upsert_all(bonds, unique_by: :secid, update_only: %i[
      short_name market_price ytm duration
      coupon_percent coupon_period maturity_date face_value accrued_interest
    ])
  end
end
