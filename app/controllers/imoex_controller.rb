class ImoexController < ApplicationController
  def index
    render plain: Csv::ImoexComponentSerializer.call(ImoexComponent.order(weight: :desc)),
           content_type: "text/csv"
  end
end
