class CreateClassCreditPurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :class_credit_purchases do |t|
      t.integer :user_id
      t.integer :group_class_id, null: false
      t.integer :sessions_count, null: false, default: 1
      t.decimal :price_paid, precision: 15, scale: 2, default: 0
      t.datetime :purchase_date
      t.integer :status, null: false, default: 0
      t.string :order_id
      t.timestamps
    end
    add_index :class_credit_purchases, :order_id, unique: true
    add_index :class_credit_purchases, [:user_id, :group_class_id]
  end
end
