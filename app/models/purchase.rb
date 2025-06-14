class Purchase < ApplicationRecord
	has_secure_token :order_id

	belongs_to :user
	belongs_to :productable, polymorphic: true

	validates_presence_of :gross_amount, :order_id, :token
	validates_uniqueness_of :order_id

	default_scope { order(created_at: :desc) }
	scope :paid_products, -> { where(productable_type: 'Product', status_code: ["200", "201"]) }

	# Hooks
	after_initialize :init_record, if: :new_record?

	def init_record
		self.order_id = self.productable.order_id
		self.gross_amount = self.productable.total_price.to_i if self.gross_amount.blank?
		self.token = ApiMidtrans.request_token(self) if self.token.blank?
	end

	def save_with_result(data)
		self.status_code = data[:status_code]
		self.status_message = data[:status_message]
		self.transaction_id = data[:transaction_id]
		self.masked_card = data[:masked_card]
		self.order_id = data[:order_id]
		self.gross_amount = data[:gross_amount]
		self.payment_type = data[:payment_type]
		self.transaction_time = data[:transaction_time]
		self.transaction_status = data[:transaction_status]
		self.fraud_status = data[:fraud_status]
		self.approval_code = data[:approval_code]
		self.bank = data[:bank]
		self.card_type = data[:card_type]
		self.save_token_id = data[:saved_token_id] if data[:saved_token_id]
		self.saved_token_id_expired_at = data[:saved_token_id_expired_at] if data[:saved_token_id_expired_at]
		self.channel_response_code = data[:channel_response_code] if data[:channel_response_code]
		self.channel_response_message = data[:channel_response_message] if data[:channel_response_message]
		self.save
	rescue StandardError => e
		puts "message: #{e.message}"
		return false
	end

	def make_settlement!
		s1 = true
		begin
			self.status_code = "200"
			self.status_message = "Success, Bank Transfer transaction is successful"
			self.transaction_status = "settlement"
			self.save!
			process_after_success!
		rescue Exception => e
			s1 = false
			puts e.message
		end
		return s1
	end

	def process_after_success!
    if self.productable.is_a? Booking
			self.productable.paid!
			self.productable.send_email_notification!
		end
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.gross_amount, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end

	def self.to_csv(data, type, options = {})
		cols = ["ID", "Name", "Email", "Phone", "Gross Amount", "Payment Type", "Status", "Type", "Date"]
		CSV.generate(options) do |csv|
			csv << cols
			data.each do |purchase|
				csv << [purchase.id, purchase.user.full_name, purchase.user.email, purchase.user.phone.to_s,
						purchase.price_label, purchase.payment_type, "( #{purchase.status_code} ) #{purchase.status_message}",
						purchase.productable_type,
						purchase.created_at.strftime('%d-%m-%Y %H:%M')]
			end
		end
	end
end
