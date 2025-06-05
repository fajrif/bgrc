class CreateBookings < ActiveRecord::Migration[7.1]
  def change
    create_table :bookings do |t|
			t.integer  :user_id
			t.integer  :court_id
			t.datetime :date
      t.datetime :end_date
			t.integer  :duration, null: false, default: 1
			t.integer  :status, null: false, default: 0
			t.string   :notes
      t.decimal :price, null: false, default: 0.0
      t.timestamps
    end
    add_index :bookings, :user_id
    add_index :bookings, :court_id
  end
end
