class CreateGroupClassPacks < ActiveRecord::Migration[7.1]
  def change
    create_table :group_class_packs do |t|
      t.references :group_class, null: false, foreign_key: true
      t.integer :sessions_count, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.string  :label
      t.integer :position, default: 0
      t.timestamps
    end
  end
end
