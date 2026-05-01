class UpdateImoex
  def call
    components = MoexClient.new.fetch_imoex
    if components.empty?
      Rails.logger.warn("UpdateImoex: empty response, skipping refresh")
      return
    end

    now = Time.current
    rows = components.map { |c| c.merge(created_at: now, updated_at: now) }

    ImoexComponent.transaction do
      ImoexComponent.delete_all
      ImoexComponent.insert_all(rows)
    end

    Rails.logger.info("UpdateImoex: refreshed #{rows.size} components")
  end
end
