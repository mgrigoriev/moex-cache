class StocksController < ApplicationController
  def index
    render plain: StockCsvSerializer.call(Stock.order(:secid)), content_type: "text/csv"
  end
end
