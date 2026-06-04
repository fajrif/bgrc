class CreateGolfBusinessHours < ActiveRecord::Migration[7.1]
  def change
    create_table :golf_business_hours do |t|
      t.references :golf_course, null: false, foreign_key: true
      t.integer :day_code, null: false
      t.string :day_name
      t.string :open, default: "06:00"
      t.string :close, default: "18:00"
      t.boolean :closed, default: false

      t.timestamps
    end
  end
end
