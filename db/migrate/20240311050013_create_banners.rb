class CreateBanners < ActiveRecord::Migration[7.1]
  def change
    create_table :banners do |t|
      t.integer :order_no, null: false, default: 0
      t.jsonb :title, default: {}
      t.jsonb :description, default: {}
			t.references :banner_section
      t.timestamps
    end
  end
end
