class AddGatewayFieldsToPurchases < ActiveRecord::Migration[7.1]
	def up
		add_column :purchases, :payment_gateway, :string
		add_column :purchases, :gateway_reference, :string
		add_column :purchases, :checkout_url, :string
		add_column :purchases, :expires_at, :datetime
		add_column :purchases, :paid_at, :datetime
		add_column :purchases, :callback_payload, :jsonb, default: {}

		# Existing rows all predate Xendit. Cashier rows never touched a gateway at
		# all and must stay out of reconciliation, so they get their own marker.
		execute <<~SQL
			UPDATE purchases SET payment_gateway = 'cashier' WHERE payment_type = 'CASHIER';
			UPDATE purchases SET payment_gateway = 'midtrans' WHERE payment_gateway IS NULL;
		SQL

		# Deliberately no column default: Purchase#init_record stamps the gateway that
		# is active when the row is built, so the model stays the single authority.
		change_column_null :purchases, :payment_gateway, false

		# order_id uniqueness was only ever enforced in the model. The webhook looks
		# rows up by it and relies on there being exactly one.
		add_index :purchases, :order_id, unique: true
		add_index :purchases, :gateway_reference
		add_index :purchases, :payment_gateway
	end

	def down
		remove_index :purchases, :payment_gateway
		remove_index :purchases, :gateway_reference
		remove_index :purchases, :order_id
		remove_column :purchases, :callback_payload
		remove_column :purchases, :paid_at
		remove_column :purchases, :expires_at
		remove_column :purchases, :checkout_url
		remove_column :purchases, :gateway_reference
		remove_column :purchases, :payment_gateway
	end
end
