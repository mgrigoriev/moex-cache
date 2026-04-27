class UpdateCorporateBondsJob < ApplicationJob
  queue_as :default

  def perform
    UpdateCorporateBonds.new.call
  end
end
