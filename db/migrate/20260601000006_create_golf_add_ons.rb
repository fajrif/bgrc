class CreateGolfAddOns < ActiveRecord::Migration[7.1]
  def change
    create_table :golf_add_ons do |t|
      t.references :golf_reservation, null: false, foreign_key: true
      t.references :golf_item, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.decimal :price, precision: 15, scale: 2, default: 0

      t.timestamps
    end
  end
end
