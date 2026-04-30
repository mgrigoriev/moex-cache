class CorporateBondsController < ApplicationController
  def index
    render plain: Csv::CorporateBondSerializer.call(CorporateBond.order(:secid)), content_type: "text/csv"
  end
end
