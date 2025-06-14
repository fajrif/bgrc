class AddOrderIdToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :order_id, :string, null: false, default: ""
  end
end
