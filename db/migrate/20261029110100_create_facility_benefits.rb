class CreateFacilityBenefits < ActiveRecord::Migration[7.1]
  def change
    create_table :facility_benefits do |t|
      t.integer :facility_id
      t.jsonb :title, default: {}
      t.jsonb :description, default: {}
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :facility_benefits, :facility_id
  end
end
