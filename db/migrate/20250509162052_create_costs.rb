class CreateCosts < ActiveRecord::Migration[7.1]
  def change
    create_table :costs do |t|
      t.integer :court_id, null: false, default: 0
      t.integer :day_code, null: false, default: 0
      t.string :day_name, null: false, default: ""
      t.string :start_time, null: false, default: "16:00"
			t.string :end_time, null: false, default: "22:00"
			t.decimal :price, null: false, default: 0.0
    end
    add_index :costs, :court_id
  end
end
