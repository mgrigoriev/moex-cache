class SetInitialPortfolioStocks < ActiveRecord::Migration[8.1]
  TICKERS = %w[
    SBERP LKOH GAZP ROSN TATNP GMKN NVTK CHMF NLMK LSNGP
    TRNFP YDEX MOEX PHOR MTSS IRAO MAGN RTKMP MGNT
  ].freeze

  def up
    quoted = TICKERS.map { |t| connection.quote(t) }.join(", ")
    execute("UPDATE stocks SET in_portfolio = true WHERE secid IN (#{quoted})")
  end

  def down
    quoted = TICKERS.map { |t| connection.quote(t) }.join(", ")
    execute("UPDATE stocks SET in_portfolio = false WHERE secid IN (#{quoted})")
  end
end
