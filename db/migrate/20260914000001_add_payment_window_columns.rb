class AddPaymentWindowColumns < ActiveRecord::Migration[7.1]
  TABLES = %i[bookings golf_reservations food_orders class_credit_purchases].freeze

  def up
    # ClassCreditPurchase#expires_at already means how long a paid pack's credits stay valid, so its
    # payment deadline needs a column of its own.
    add_column :class_credit_purchases, :payment_expires_at, :datetime

    TABLES.each do |table|
      add_column table, :payment_window_reset_at, :datetime
      add_column table, :checkout_extended_at, :datetime
    end

    add_column :food_orders, :needs_attention, :boolean, default: false, null: false

    # The expiry sweep looks rows up by status and deadline.
    add_index :bookings, [:status, :expires_at]
    add_index :golf_reservations, [:status, :expires_at]
    add_index :food_orders, [:status, :expires_at]
    add_index :class_credit_purchases, [:status, :payment_expires_at]

    # Pending packs never had a payment deadline. Give each the window it would have had, so
    # abandoned ones get retired instead of staying pending forever.
    minutes = Integer(ENV.fetch("PAYMENT_WINDOW_MINUTES", 10))
    execute <<~SQL
      UPDATE class_credit_purchases
      SET payment_expires_at = created_at + INTERVAL '#{minutes} minutes'
      WHERE status = 0
    SQL
  end

  def down
    remove_index :class_credit_purchases, [:status, :payment_expires_at]
    remove_index :food_orders, [:status, :expires_at]
    remove_index :golf_reservations, [:status, :expires_at]
    remove_index :bookings, [:status, :expires_at]

    remove_column :food_orders, :needs_attention

    TABLES.each do |table|
      remove_column table, :checkout_extended_at
      remove_column table, :payment_window_reset_at
    end

    remove_column :class_credit_purchases, :payment_expires_at
  end
end
