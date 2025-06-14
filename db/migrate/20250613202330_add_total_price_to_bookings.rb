class AddTotalPriceToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :total_price, :decimal, null: false, default: 0.0
  end
end
