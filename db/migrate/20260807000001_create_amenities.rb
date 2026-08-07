class CreateAmenities < ActiveRecord::Migration[7.1]
  def change
    create_table :amenities do |t|
      t.jsonb :name, default: {}
      t.jsonb :short_description, default: {}
      t.integer :facility_id
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :amenities, :facility_id
  end
end
