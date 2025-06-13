class AddColumnToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :court_type, :integer
    add_column :bookings, :class_type, :integer, null: false, default: 0
    add_column :bookings, :coach_id, :integer
    add_column :bookings, :price_coach, :decimal, null: false, default: 0.0
  end
end
