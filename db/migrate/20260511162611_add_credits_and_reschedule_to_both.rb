class AddCreditsAndRescheduleToBoth < ActiveRecord::Migration[7.1]
  def change
    # ClassCreditPurchase: expiry date and initial session date for auto-booking
    add_column :class_credit_purchases, :expires_at, :datetime
    add_column :class_credit_purchases, :initial_session_date, :datetime

    # Bookings: track reschedule count and refund flag
    add_column :bookings, :reschedule_count, :integer, default: 0, null: false
    add_column :bookings, :refunded, :boolean, default: false, null: false
  end
end
