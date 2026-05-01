class UpdateImoex
  def call
    components = MoexClient.new.fetch_imoex
    return if components.empty?

    now = Time.current
    rows = components.map { |c| c.merge(created_at: now, updated_at: now) }

    ImoexComponent.transaction do
      ImoexComponent.delete_all
      ImoexComponent.insert_all(rows)
    end
  end
end
