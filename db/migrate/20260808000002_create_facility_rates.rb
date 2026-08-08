class CreateFacilityRates < ActiveRecord::Migration[7.1]
  def change
    create_table :facility_rates do |t|
      t.integer :facility_id
      t.jsonb   :name, default: {}
      t.jsonb   :access, default: {}
      t.string  :time, default: "", null: false
      t.string  :price, default: "", null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :facility_rates, :facility_id
  end
end
