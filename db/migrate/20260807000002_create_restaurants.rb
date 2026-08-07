class CreateRestaurants < ActiveRecord::Migration[7.1]
  def change
    create_table :restaurants do |t|
      t.jsonb :slug, default: {}
      t.jsonb :name, default: {}
      t.jsonb :short_description, default: {}
      t.jsonb :description, default: {}
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :restaurants, :slug, unique: true
    add_index :restaurants, :name, unique: true
  end
end
