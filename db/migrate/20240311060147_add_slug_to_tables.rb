class AddSlugToTables < ActiveRecord::Migration[7.1]
  def change
		add_column :articles, :slug, :jsonb, default: {}
    add_index :articles, :slug, unique: true
  end
end
