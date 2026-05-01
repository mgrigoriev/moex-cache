class MoexbcController < ApplicationController
  def index
    render plain: Csv::MoexbcComponentSerializer.call(MoexbcComponent.order(weight: :desc)),
           content_type: "text/csv"
  end
end
