class AddProductableToPurchases < ActiveRecord::Migration[7.1]
  def change
		# Add reference polymorphic
		add_reference :purchases, :productable, polymorphic: true, index: true
		# Add columns
		add_column :purchases, :token, :string
		add_column :purchases, :status_code, :string, default: "000"
		add_column :purchases, :status_message, :string, default: "Initialize Object"
		add_column :purchases, :transaction_id, :string
		add_column :purchases, :masked_card, :string
		add_column :purchases, :order_id, :string
		add_column :purchases, :gross_amount, :string
		add_column :purchases, :payment_type, :string
		add_column :purchases, :transaction_time, :string
		add_column :purchases, :transaction_status, :string
		add_column :purchases, :fraud_status, :string
		add_column :purchases, :approval_code, :string
		add_column :purchases, :bank, :string
		add_column :purchases, :card_type, :string
		add_column :purchases, :save_token_id, :string
		add_column :purchases, :saved_token_id_expired_at, :string
		add_column :purchases, :channel_response_code, :string
		add_column :purchases, :channel_response_message, :string
  end
end
