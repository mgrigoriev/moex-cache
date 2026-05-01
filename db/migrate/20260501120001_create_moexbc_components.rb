class CreateMoexbcComponents < ActiveRecord::Migration[8.1]
  def change
    create_table :moexbc_components do |t|
      t.string :ticker, null: false
      t.decimal :weight, null: false, precision: 7, scale: 6

      t.timestamps
    end

    add_index :moexbc_components, :ticker, unique: true
  end
end
