class FundsController < ApplicationController
  def index
    render plain: FundCsvSerializer.call(Fund.order(:secid)), content_type: "text/csv"
  end
end
