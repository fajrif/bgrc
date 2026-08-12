class CreateMenuCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :menu_categories do |t|
      t.jsonb   :name, default: {}
      # The filter tabs on the Grab & Go page key off the slug, so it stays a plain
      # string — a translated key would change the markup between locales.
      t.string  :slug, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :menu_categories, :slug, unique: true
  end
end
