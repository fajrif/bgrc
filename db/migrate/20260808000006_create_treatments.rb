class CreateTreatments < ActiveRecord::Migration[7.1]
  def change
    create_table :treatments do |t|
      t.integer :facility_id
      t.jsonb   :name, default: {}
      t.jsonb   :short_description, default: {}
      t.string  :duration, default: "", null: false
      t.string  :price, default: "", null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :treatments, :facility_id
  end
end
