class CreateFacilities < ActiveRecord::Migration[7.1]
  def change
    create_table :facilities do |t|
      t.jsonb :name, default: {}
      t.jsonb :short_description, default: {}
      t.jsonb :description, default: {}
      t.timestamps null: false
    end
    add_index :facilities, :name, unique: true
  end
end
