class AddGroupClassToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :group_class_id, :integer
    add_column :bookings, :pax, :integer, null: false, default: 0
  end
end
