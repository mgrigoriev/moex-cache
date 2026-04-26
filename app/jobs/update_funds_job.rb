class UpdateFundsJob < ApplicationJob
  queue_as :default

  def perform
    UpdateFunds.new.call
  end
end
