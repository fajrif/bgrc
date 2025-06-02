class AddFeaturedToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :featured, :integer, null: false, default: 0
  end
end
