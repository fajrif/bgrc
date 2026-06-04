class CreateGolfRates < ActiveRecord::Migration[7.1]
  def change
    create_table :golf_rates do |t|
      t.references :golf_course, null: false, foreign_key: true
      t.integer :holes, null: false
      t.integer :day_type, null: false, default: 0
      t.decimal :price, precision: 15, scale: 2, null: false
      t.string :label

      t.timestamps
    end
  end
end
