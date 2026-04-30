class OfzController < ApplicationController
  def index
    render plain: Csv::OfzSerializer.call(Ofz.order(:secid)), content_type: "text/csv"
  end
end
