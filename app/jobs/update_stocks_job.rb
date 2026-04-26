class UpdateStocksJob < ApplicationJob
  queue_as :default

  def perform
    UpdateStocks.new.call
  end
end
