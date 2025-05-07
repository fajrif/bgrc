class AddSlugToOtherTables < ActiveRecord::Migration[7.1]
  def change
		add_column :facilities, :slug, :jsonb, default: {}
    add_index :facilities, :slug, unique: true
		add_column :sports, :slug, :string, default: ""
    add_index :sports, :slug, unique: true
		add_column :events, :slug, :jsonb, default: {}
    add_index :events, :slug, unique: true
		add_column :promos, :slug, :jsonb, default: {}
    add_index :promos, :slug, unique: true
  end
end
