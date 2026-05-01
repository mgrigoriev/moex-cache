class AddDividendForecastToStocks < ActiveRecord::Migration[8.1]
  def change
    add_column :stocks, :dividend_forecast, :decimal, precision: 10, scale: 2
  end
end
