class CreateCorporateBonds < ActiveRecord::Migration[8.1]
  def change
    create_table :corporate_bonds do |t|
      t.string :secid, null: false
      t.string :short_name
      t.decimal :market_price
      t.decimal :ytm
      t.integer :duration
      t.decimal :coupon_percent
      t.integer :coupon_period
      t.date :maturity_date
      t.decimal :face_value
      t.decimal :accrued_interest

      t.timestamps
    end

    add_index :corporate_bonds, :secid, unique: true
  end
end
