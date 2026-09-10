# Which payment gateway a checkout goes through, and which one an existing
# purchase came from. Adapters live in app/services/payment_gateways/ and all
# answer the same four questions (see PaymentGateways::Base).
module PaymentGateways
	class Error < StandardError; end
	class ConfigurationError < Error; end
	class RequestError < Error; end

	# Cashier purchases are recorded by staff at the counter and never touch a
	# gateway, so they resolve to no adapter at all.
	CASHIER = "cashier".freeze

	# The internal status vocabulary every adapter normalises into. Defined on the
	# module rather than on Base so that the adapters' `class << self` methods can
	# see them: singleton-class constant lookup reaches the enclosing module, but
	# not the superclass.
	INITIALIZED_CODE = "000".freeze
	SUCCESS_CODE     = "200".freeze
	PENDING_CODE     = "000".freeze
	EXPIRED_CODE     = "407".freeze
	FAILED_CODE      = "412".freeze

	# What a gateway hands back when a checkout is opened. Not every gateway fills
	# every field: Midtrans has a Snap token and no URL of its own, Xendit has a
	# hosted invoice URL and no token.
	Checkout = Struct.new(:checkout_url, :gateway_reference, :expires_at, :token, keyword_init: true)

	# The normalised view of a callback or a status fetch. `outcome` drives what the
	# app does; `attributes` is written straight onto the Purchase.
	Result = Struct.new(:outcome, :attributes, keyword_init: true) do
		def paid?    = outcome == :paid
		def expired? = outcome == :expired
		def pending? = outcome == :pending
		def failed?  = outcome == :failed
	end

	ADAPTERS = {
		"xendit"   => "PaymentGateways::Xendit",
		"midtrans" => "PaymentGateways::Midtrans",
	}.freeze

	# The gateway new checkouts are sent to.
	def self.current
		resolve(current_name)
	end

	def self.current_name
		configatron.payment_gateway.to_s
	end

	# The gateway that actually handled a given purchase. Reading this off the row
	# rather than off config is what lets historical Midtrans purchases keep
	# rendering correctly after the switch to Xendit.
	def self.for(purchase)
		resolve(purchase.payment_gateway)
	end

	def self.resolve(name)
		name = name.to_s
		raise ConfigurationError, "#{name} purchases are not processed by a gateway" if name == CASHIER

		const_name = ADAPTERS[name]
		raise ConfigurationError, "Unknown payment gateway #{name.inspect}" if const_name.nil?

		const_name.constantize
	end
end
