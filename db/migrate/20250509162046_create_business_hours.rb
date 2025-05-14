class CreateBusinessHours < ActiveRecord::Migration[7.1]
  def change
    create_table :business_hours do |t|
      t.integer :court_id, null: false, default: 0
      t.integer :day_code, null: false, default: 0
      t.string :day_name, null: false, default: ""
      t.string :open, null: false, default: "06:00"
      t.string :close, null: false, default: "22:00"
    end
    add_index :business_hours, :court_id
  end
end
