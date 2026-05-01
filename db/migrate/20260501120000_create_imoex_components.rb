class CreateImoexComponents < ActiveRecord::Migration[8.1]
  def change
    create_table :imoex_components do |t|
      t.string :ticker, null: false
      t.decimal :weight, null: false, precision: 7, scale: 6

      t.timestamps
    end

    add_index :imoex_components, :ticker, unique: true
  end
end
