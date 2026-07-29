class CreateHighlights < ActiveRecord::Migration[7.1]
  def change
    create_table :highlights do |t|
      t.jsonb :title, default: {}
      t.jsonb :short_description, default: {}
      t.jsonb :slug, default: {}
      t.jsonb :meta_title, default: {}
      t.jsonb :meta_description, default: {}
      t.references :category
      t.datetime :published_date
      t.integer :status, null: false, default: 1
      t.string :tags, null: false, default: ""
      t.integer :position, null: false, default: 0
      t.timestamps null: false
    end
    add_index :highlights, :title, unique: true
    add_index :highlights, :slug, unique: true
  end
end
