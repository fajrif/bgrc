class CreateCoaches < ActiveRecord::Migration[7.1]
  def change
    create_table :coaches do |t|
      t.string :name, null: false, default: ""
      t.string :email, null: false, default: ""
      t.string :phone, null: false, default: ""
      t.integer :gender, null: false, default: 1
			t.decimal :price, null: false, default: 0.0
    end
  end
end
