class AddPageHeadingToFacilities < ActiveRecord::Migration[7.1]
  def change
    add_column :facilities, :page_heading, :jsonb, default: {}
  end
end
