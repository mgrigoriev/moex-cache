class OfzController < ApplicationController
  def index
    render plain: OfzCsvSerializer.call(Ofz.order(:secid)), content_type: "text/csv"
  end
end
