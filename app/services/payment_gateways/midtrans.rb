require "digest"

module PaymentGateways
	# Snap. Kept as a working fallback so PAYMENT_GATEWAY can be flipped back
	# without a deploy.
	#
	# Ported from the old ApiMidtrans, with two things it never had: verified
	# notifications and a status lookup. Both are needed for the fallback to be
	# safe rather than a return to trusting the browser.
	class Midtrans < Base
		class << self
			def checkout(purchase)
				status, body = post_json(
					configatron.midtrans_api_url,
					{
						"transaction_details" => {
							"order_id" => purchase.order_id.to_s,
							"gross_amount" => purchase.gross_amount.to_i,
						},
						"item_details" => item_details(purchase),
						"customer_details" => {
							"first_name" => purchase.user.full_name,
							"email" => purchase.user.email,
						},
						"credit_card" => { "secure" => true, "save_card" => true, "save_token_id" => true },
					},
					basic_auth_user: server_key,
				)

				unless status == 201 && body["token"].present?
					raise RequestError, "Midtrans rejected the transaction (HTTP #{status}): #{body}"
				end

				# Snap renders in-page from the token; there is no URL to send the user to.
				Checkout.new(token: body["token"], gateway_reference: purchase.order_id.to_s)
			end

			# Midtrans signs notifications rather than sending a shared header token.
			def verify_callback(request)
				payload = callback_payload(request)
				expected = Digest::SHA512.hexdigest(
					"#{payload['order_id']}#{payload['status_code']}#{payload['gross_amount']}#{server_key}"
				)
				given = payload["signature_key"].to_s
				return false if given.blank?

				ActiveSupport::SecurityUtils.secure_compare(expected, given)
			end

			def normalize_callback(payload)
				attributes = {
					status_code: payload["status_code"].presence || PENDING_CODE,
					status_message: payload["status_message"],
					transaction_id: payload["transaction_id"],
					transaction_time: payload["transaction_time"],
					transaction_status: payload["transaction_status"],
					fraud_status: payload["fraud_status"],
					payment_type: payload["payment_type"],
					masked_card: payload["masked_card"],
					approval_code: payload["approval_code"],
					bank: payload["bank"],
					card_type: payload["card_type"],
					gateway_reference: payload["transaction_id"],
				}

				outcome = outcome_for(payload["transaction_status"], payload["fraud_status"])
				attributes[:status_code] = SUCCESS_CODE if outcome == :paid
				attributes[:status_code] = EXPIRED_CODE if outcome == :expired
				attributes[:paid_at] = parse_time(payload["settlement_time"] || payload["transaction_time"]) if outcome == :paid

				Result.new(outcome: outcome, attributes: attributes)
			end

			def fetch_status(purchase)
				status, body = get_json(
					"#{configatron.midtrans_status_api_url}/#{purchase.order_id}/status",
					basic_auth_user: server_key,
				)
				return nil unless status == 200

				normalize_callback(body)
			rescue RequestError => e
				Rails.logger.warn("[midtrans] status lookup failed for #{purchase.order_id}: #{e.message}")
				nil
			end

			def callback_payload(request)
				request.request_parameters.presence || {}
			end

			private

			def outcome_for(transaction_status, fraud_status)
				case transaction_status.to_s
				when "settlement" then :paid
				when "capture" then fraud_status.to_s == "challenge" ? :pending : :paid
				when "pending" then :pending
				when "expire" then :expired
				when "deny", "cancel", "failure" then :failed
				else :pending
				end
			end

			def parse_time(value)
				return nil if value.blank?

				Time.zone.parse(value.to_s)
			rescue ArgumentError
				nil
			end

			def server_key
				key = configatron.midtrans_server_key
				raise ConfigurationError, "MIDTRANS_SERVER_KEY is not set" if key.blank?

				key
			end
		end
	end
end
