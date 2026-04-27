class CorporateBondsController < ApplicationController
  def index
    render plain: CorporateBondCsvSerializer.call(CorporateBond.order(:secid)), content_type: "text/csv"
  end
end
