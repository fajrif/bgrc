class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items do |t|
      t.string :name, null: false, default: ""
			t.decimal :price, null: false, default: 0.0
    end
  end
end
