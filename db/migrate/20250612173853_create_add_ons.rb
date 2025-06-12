class CreateAddOns < ActiveRecord::Migration[7.1]
  def change
    create_table :add_ons do |t|
			t.references :booking
			t.references :item
      t.integer :quantity, null: false, default: 1
			t.decimal :price, null: false, default: 0.0
    end
  end
end
