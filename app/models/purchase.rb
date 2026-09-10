class Purchase < ApplicationRecord
	has_secure_token :order_id

	# Internal status vocabulary. Gateway adapters normalise into these rather than
	# leaking their own, so admin filters, receipts, exports and every historical
	# row keep reading the same field they always have.
	INITIALIZED_CODE = "000".freeze
	SUCCESS_CODE     = "200".freeze
	PENDING_CODE     = "201".freeze
	EXPIRED_CODE     = "407".freeze
	SUCCESS_CODES    = [SUCCESS_CODE, PENDING_CODE].freeze

	belongs_to :user
	belongs_to :productable, polymorphic: true

	# `token` is intentionally not required: it is a Midtrans concept, and under
	# every gateway it is only known after the checkout call, which now happens
	# after the row is saved.
	validates_presence_of :gross_amount, :order_id
	validates_uniqueness_of :order_id

	default_scope { order(created_at: :desc) }
	scope :awaiting_payment, -> { where(status_code: INITIALIZED_CODE) }
	scope :through_gateway, -> { where.not(payment_gateway: PaymentGateways::CASHIER) }

	# Hooks
	after_initialize :init_record, if: :new_record?

	def init_record
		return if productable.blank?

		self.order_id = productable.order_id
		self.gross_amount = productable.total_price.to_i if gross_amount.blank?
		self.payment_gateway = PaymentGateways.current_name if payment_gateway.blank?
	end

	def paid?
		status_code.in?(SUCCESS_CODES)
	end

	def awaiting_payment?
		status_code == INITIALIZED_CODE
	end

	def cashier?
		payment_gateway == PaymentGateways::CASHIER
	end

	def gateway
		PaymentGateways.for(self)
	end

	# Opens a payment at the gateway and stores what is needed to resume or
	# reconcile it. Deliberately an explicit call rather than an after_initialize
	# hook, so that merely building a Purchase never makes a network request.
	def start_checkout!
		unless checkout_window_open?
			raise PaymentGateways::Error, "the payment window for #{productable_type} #{productable_id} has closed"
		end

		result = gateway.checkout(self)

		assign_attributes(
			token: result.token.presence || token,
			checkout_url: result.checkout_url,
			gateway_reference: result.gateway_reference,
			expires_at: result.expires_at,
		)
		save!
		self
	end

	# The one place a purchase is allowed to change payment state, whether the news
	# arrives by webhook, by an on-return status fetch, or by the reconciliation
	# sweep. Idempotent under lock, because gateways retry callbacks.
	def apply_gateway_result!(result, payload: nil)
		outcome = nil

		with_lock do
			if paid?
				outcome = :already_settled
			else
				assign_attributes(result.attributes.compact)
				self.callback_payload = payload if payload.present?
				save!

				outcome =
					if result.paid?
						process_after_success!
						:settled
					elsif result.expired?
						expire_productable!
						:expired
					else
						:noop
					end
			end
		end

		outcome
	end

	# How long the gateway should keep this payment open. The window belongs to the
	# product, not to the purchase, so a user who clicks Pay three minutes into a
	# ten-minute booking window gets the remaining seven — not a fresh ten.
	def checkout_window_seconds
		# ClassCreditPurchase#expires_at is credit *validity* (months out), not a
		# payment window, so it must never be read as one.
		return configatron.class_credit_payment_window_hours.hours.to_i if productable.is_a?(ClassCreditPurchase)

		deadline = productable.try(:expires_at)
		return configatron.payment_window_minutes.minutes.to_i if deadline.blank?

		[(deadline - Time.current).to_i, 0].max
	end

	def checkout_window_open?
		checkout_window_seconds.positive?
	end

	# Where the gateway sends the customer back to. Bookings, tee times and food
	# orders are all addressed by order_id; class credits by id.
	def checkout_return_url(status:)
		helpers = Rails.application.routes.url_helpers
		options = self.class.site_url_options.merge(payment: status)

		# `id:` is passed by name on purpose: every public route is wrapped in an
		# optional "(:locale)" segment, which swallows a positional argument.
		case productable
		when Booking             then helpers.booking_url(id: productable.order_id, **options)
		when GolfReservation     then helpers.golf_reservation_url(id: productable.order_id, **options)
		when FoodOrder           then helpers.food_order_url(id: productable.order_id, **options)
		when ClassCreditPurchase then helpers.class_credit_purchase_url(id: productable.id, **options)
		else helpers.root_url(**options)
		end
	end

	def self.site_url_options
		raw = configatron.site_url.to_s
		uri = URI.parse(raw.start_with?("http") ? raw : "http://#{raw}")
		options = { protocol: uri.scheme, host: uri.host }
		options[:port] = uri.port unless [80, 443].include?(uri.port)
		options
	end

	# Staff recording a counter payment. Never touches a gateway, so it is stamped
	# as such and stays out of reconciliation.
	def make_settlement!
		s1 = true
		begin
			self.status_code = SUCCESS_CODE
			self.status_message = "Success, Bank Transfer transaction is successful"
			self.transaction_status = "settlement"
			self.paid_at ||= Time.current
			self.save!
			process_after_success!
		rescue Exception => e
			s1 = false
			Rails.logger.error("[purchase #{id}] manual settlement failed: #{e.message}")
		end
		return s1
	end

	def process_after_success!
    if self.productable.is_a?(Booking)
			self.productable.paid!
			self.productable.send_email_notification!
    elsif self.productable.is_a?(GolfReservation)
      self.productable.paid!
      self.productable.send_email_notification!
    elsif self.productable.is_a?(ClassCreditPurchase)
      self.productable.mark_paid!
      self.productable.book_initial_session!
    elsif self.productable.is_a?(FoodOrder)
      self.productable.paid!
      self.productable.send_email_notification!
		end
	end

	def price_label
		ActionController::Base.helpers.number_to_currency(self.gross_amount, unit: "Rp. ", separator: ",", delimiter: ".", precision: 0)
	end

	private

	def expire_productable!
		return unless productable.respond_to?(:expire!)
		return if productable.respond_to?(:is_unpaid?) && !productable.is_unpaid?

		productable.expire!
	end

end
