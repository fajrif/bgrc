class CreateBannerSections < ActiveRecord::Migration[7.1]
  def change
    create_table :banner_sections do |t|
      t.string :name, null: false, default: ""
      t.integer :style, null: false, default: 0
      t.integer :size, null: false, default: 0
    end
  end
end
