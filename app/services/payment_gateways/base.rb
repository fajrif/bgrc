require "net/http"
require "uri"
require "json"

module PaymentGateways
	# Interface every gateway adapter implements, plus the shared HTTP plumbing.
	#
	# Adapters translate between the gateway's own vocabulary and this app's, which
	# stays the Midtrans-shaped `status_code` the whole codebase already reads
	# (admin filters, receipts, scopes, and every existing row).
	class Base
		class << self
			# Open a payment for `purchase`. Returns a Checkout, or raises RequestError.
			def checkout(purchase)
				raise NotImplementedError
			end

			# Is this inbound webhook genuinely from the gateway?
			def verify_callback(request)
				raise NotImplementedError
			end

			# Turn a raw callback body into a Result.
			def normalize_callback(payload)
				raise NotImplementedError
			end

			# Ask the gateway where a purchase actually stands. Used to close the
			# race when a user returns before the webhook lands, and by the
			# reconciliation sweep. Returns a Result, or nil if the gateway cannot
			# answer (unknown reference, transport failure).
			def fetch_status(purchase)
				raise NotImplementedError
			end

			# Most products are a single line — one booking, one tee time, one credit
			# pack. A product made of several priced things (a Grab & Go order) hands
			# over its own breakdown instead.
			def item_details(purchase)
				if purchase.productable.respond_to?(:gateway_item_details)
					lines = purchase.productable.gateway_item_details
					return lines if lines.present?
				end

				[{
					"id" => purchase.productable.id.to_s,
					"price" => purchase.gross_amount.to_i,
					"quantity" => 1,
					"name" => purchase.productable.name.to_s,
					"category" => purchase.productable_type.to_s,
				}]
			end

			private

			def post_json(url, body, basic_auth_user:, headers: {})
				uri = URI.parse(url)
				request = Net::HTTP::Post.new(uri)
				request.body = JSON.dump(body)
				send_request(uri, request, basic_auth_user, headers)
			end

			def get_json(url, basic_auth_user:, headers: {})
				uri = URI.parse(url)
				request = Net::HTTP::Get.new(uri)
				send_request(uri, request, basic_auth_user, headers)
			end

			# Returns [Integer status, Hash body]. Raises RequestError on transport
			# failure so callers never have to distinguish nil-from-timeout against
			# nil-from-empty-response.
			def send_request(uri, request, basic_auth_user, headers)
				request.content_type = "application/json"
				request["Accept"] = "application/json"
				request.basic_auth(basic_auth_user, "")
				headers.each { |key, value| request[key] = value }

				http = Net::HTTP.new(uri.hostname, uri.port)
				http.use_ssl = (uri.scheme == "https")
				http.open_timeout = configatron.payment_gateway_open_timeout
				http.read_timeout = configatron.payment_gateway_read_timeout

				response = http.request(request)
				[response.code.to_i, parse_body(response.body)]
			rescue Net::OpenTimeout, Net::ReadTimeout => e
				raise RequestError, "#{name}: gateway timed out (#{e.class})"
			rescue SystemCallError, OpenSSL::SSL::SSLError, IOError => e
				raise RequestError, "#{name}: #{e.class} - #{e.message}"
			end

			def parse_body(body)
				return {} if body.blank?

				JSON.parse(body)
			rescue JSON::ParserError
				{}
			end
		end
	end
end
