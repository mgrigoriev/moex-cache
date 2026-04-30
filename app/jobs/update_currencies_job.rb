class UpdateCurrenciesJob < ApplicationJob
  queue_as :default

  def perform
    UpdateCurrencies.new.call
  end
end
