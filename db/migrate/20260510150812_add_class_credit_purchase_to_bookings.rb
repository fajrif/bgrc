class AddClassCreditPurchaseToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :class_credit_purchase_id, :integer
  end
end
