class AddSlugToPackages < ActiveRecord::Migration[7.1]
  def change
		add_column :packages, :slug, :jsonb, default: {}
    add_index :packages, :slug, unique: true
  end
end
