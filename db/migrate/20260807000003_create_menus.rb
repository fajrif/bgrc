class CreateMenus < ActiveRecord::Migration[7.1]
  def change
    create_table :menus do |t|
      t.jsonb :name, default: {}
      t.jsonb :short_description, default: {}
      t.integer :restaurant_id
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :menus, :restaurant_id
  end
end
