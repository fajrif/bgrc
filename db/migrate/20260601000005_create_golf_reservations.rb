class CreateGolfReservations < ActiveRecord::Migration[7.1]
  def change
    create_table :golf_reservations do |t|
      t.references :user, null: true, foreign_key: true
      t.references :golf_course, null: false, foreign_key: true
      t.datetime :tee_time, null: false
      t.integer :players_count, null: false, default: 1
      t.integer :holes, null: false, default: 18
      t.integer :status, null: false, default: 0
      t.string :order_id, null: false
      t.datetime :expires_at
      t.decimal :green_fee, precision: 15, scale: 2, default: 0
      t.decimal :total_price, precision: 15, scale: 2, default: 0
      t.string :notes
      t.jsonb :player_names, default: []
      t.boolean :refunded, default: false

      t.timestamps
    end

    add_index :golf_reservations, :order_id, unique: true
  end
end
