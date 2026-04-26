class CreateFunds < ActiveRecord::Migration[8.1]
  def change
    create_table :funds do |t|
      t.string :secid, null: false
      t.decimal :market_price, null: false

      t.timestamps
    end

    add_index :funds, :secid, unique: true
  end
end
