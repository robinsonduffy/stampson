class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :scott_number
      t.text :description
      t.integer :country_id

      t.timestamps
    end
    add_index :items, [:scott_number, :country_id], :unique => true
  end

  def self.down
    drop_table :items
  end
end
