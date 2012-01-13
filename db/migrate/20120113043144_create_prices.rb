class CreatePrices < ActiveRecord::Migration
  def self.up
    create_table :prices do |t|
      t.string :condition
      t.decimal :price, :precision => 8, :scale => 2
      t.integer :item_id

      t.timestamps
    end
    add_index :prices, [:item_id, :condition], :unique => true
  end

  def self.down
    drop_table :prices
  end
end
