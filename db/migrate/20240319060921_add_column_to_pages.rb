class AddColumnToPages < ActiveRecord::Migration[7.1]
  def change
		add_column :articles, :meta_title, :jsonb, default: {}
		add_column :articles, :meta_description, :jsonb, default: {}
  end
end
