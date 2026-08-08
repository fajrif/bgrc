class CreateFacilityDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :facility_details do |t|
      t.integer :facility_id
      t.jsonb   :title, default: {}
      t.jsonb   :body, default: {}
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :facility_details, :facility_id
  end
end
