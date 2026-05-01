class UpdateDividendForecastsJob < ApplicationJob
  queue_as :default

  def perform
    UpdateDividendForecasts.new.call
  end
end
