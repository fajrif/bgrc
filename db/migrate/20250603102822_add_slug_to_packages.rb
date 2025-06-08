class AddSlugToPackages < ActiveRecord::Migration[7.1]
  def change
		add_column :packages, :slug, :jsonb, default: {}
    add_index :packages, :slug, unique: true
		add_column :courts, :slug, :string, default: ""
    add_index :courts, :slug, unique: true
  end
end
