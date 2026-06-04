class CreateGolfItems < ActiveRecord::Migration[7.1]
  def change
    create_table :golf_items do |t|
      t.string :name, null: false
      t.decimal :price, precision: 15, scale: 2, null: false
      t.integer :price_type, default: 0
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :golf_items, :name, unique: true
  end
end
