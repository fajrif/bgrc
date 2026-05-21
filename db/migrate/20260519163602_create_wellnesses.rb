class CreateWellnesses < ActiveRecord::Migration[7.1]
  def change
    create_table :wellnesses do |t|
      t.jsonb :name, default: {}
      t.jsonb :short_description, default: {}
      t.jsonb :description, default: {}
      t.jsonb :slug, default: {}
      t.timestamps null: false
    end
    add_index :wellnesses, :name, unique: true
    add_index :wellnesses, :slug, unique: true
  end
end
