class FundsController < ApplicationController
  def index
    render plain: Csv::FundSerializer.call(Fund.order(:secid)), content_type: "text/csv"
  end
end
