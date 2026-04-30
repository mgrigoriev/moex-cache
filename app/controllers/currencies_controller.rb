class CurrenciesController < ApplicationController
  def index
    render plain: Csv::CurrencySerializer.call(Currency.order(:secid)), content_type: "text/csv"
  end
end
