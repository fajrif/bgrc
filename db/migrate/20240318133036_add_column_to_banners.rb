class AddColumnToBanners < ActiveRecord::Migration[7.1]
  def change
		add_column :banners, :orientation, :string
  end
end
