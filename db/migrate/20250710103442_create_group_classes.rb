class CreateGroupClasses < ActiveRecord::Migration[7.1]
  def change
    create_table :group_classes do |t|
			t.string  :name, null: false, default: ""
			t.integer :min_duration, null: false, default: 1
			t.integer :min_pax, null: false, default: 1
			t.integer :max_pax, null: false, default: 1
			t.integer :status, null: false, default: 1
      t.decimal :price, null: false, default: 0.0
      t.decimal :price_pax, null: false, default: 0.0
			t.string  :notes
			t.string  :description
      t.timestamps
    end
  end
end
