class AddInPortfolioToStocks < ActiveRecord::Migration[8.1]
  def change
    add_column :stocks, :in_portfolio, :boolean, default: false, null: false
    add_index :stocks, :in_portfolio
  end
end
