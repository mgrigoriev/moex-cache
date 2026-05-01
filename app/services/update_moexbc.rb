class UpdateMoexbc
  def call
    components = MoexClient.new.fetch_moexbc
    if components.empty?
      Rails.logger.warn("UpdateMoexbc: empty response, skipping refresh")
      return
    end

    now = Time.current
    rows = components.map { |c| c.merge(created_at: now, updated_at: now) }

    MoexbcComponent.transaction do
      MoexbcComponent.delete_all
      MoexbcComponent.insert_all(rows)
    end

    Rails.logger.info("UpdateMoexbc: refreshed #{rows.size} components")
  end
end
