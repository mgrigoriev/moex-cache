class UpdateMoexbc
  def call
    components = MoexClient.new.fetch_moexbc
    return if components.empty?

    now = Time.current
    rows = components.map { |c| c.merge(created_at: now, updated_at: now) }

    MoexbcComponent.transaction do
      MoexbcComponent.delete_all
      MoexbcComponent.insert_all(rows)
    end
  end
end
