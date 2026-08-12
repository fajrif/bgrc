class CreateFoodOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :food_order_items do |t|
      t.bigint  :food_order_id, null: false
      t.bigint  :menu_id, null: false
      # Name and price are snapshotted when the item is added, so a later rename,
      # price change or discount never rewrites an order that was already placed.
      t.string  :name, default: "", null: false
      t.integer :quantity, default: 1, null: false
      t.decimal :price, precision: 15, scale: 2, default: 0, null: false

      t.timestamps
    end

    add_index :food_order_items, :food_order_id
    add_index :food_order_items, :menu_id
  end
end
