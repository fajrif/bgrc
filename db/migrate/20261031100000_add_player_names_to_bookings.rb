class AddPlayerNamesToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :player_names, :jsonb, default: []
  end
end
