class AddPaxToClassCreditPurchases < ActiveRecord::Migration[7.1]
  def change
    add_column :class_credit_purchases, :pax, :integer, default: 1, null: false
  end
end
