class CreateFoodOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :food_orders do |t|
      # Guests order without an account; the row is adopted on sign-in.
      t.integer  :user_id
      t.string   :order_id, null: false
      t.integer  :status, default: 0, null: false
      t.integer  :fulfillment_status, default: 0, null: false
      t.decimal  :total_price, precision: 15, scale: 2, default: 0, null: false
      t.datetime :expires_at
      # nil means ASAP — the counter works the queue in order.
      t.datetime :pickup_at
      t.string   :customer_name
      t.string   :customer_phone
      t.text     :notes
      t.boolean  :refunded, default: false, null: false

      t.timestamps
    end

    # order_id is the URL key, so it is unique in the database and not only in the
    # model — bookings and golf reservations only validate it.
    add_index :food_orders, :order_id, unique: true
    add_index :food_orders, :user_id
  end
end
