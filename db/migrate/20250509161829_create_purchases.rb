class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
			t.belongs_to :user
			t.timestamps
    end
  end
end
