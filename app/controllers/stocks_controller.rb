class StocksController < ApplicationController
  def index
    render plain: Csv::StockSerializer.call(Stock.order(:secid)), content_type: "text/csv"
  end
end
