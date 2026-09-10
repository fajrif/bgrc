module PaymentGateways
	# Xendit Invoices (Payment Links): one API call returns a hosted checkout URL
	# covering every enabled channel — virtual accounts, QRIS, e-wallets, retail
	# outlets and cards — and the result comes back over a verified webhook rather
	# than from the browser.
	#
	# There is no separate sandbox hostname; Test Mode vs Live Mode is decided
	# entirely by which secret key is configured.
	class Xendit < Base
		# Xendit rejects durations outside this range.
		MIN_INVOICE_DURATION = 60
		MAX_INVOICE_DURATION = 31_536_000

		class << self
			def checkout(purchase)
				status, body = post_json(
					"#{base_url}/v2/invoices",
					invoice_payload(purchase),
					basic_auth_user: secret_key,
				)

				unless status.between?(200, 299) && body["invoice_url"].present?
					raise RequestError, "Xendit rejected the invoice (HTTP #{status}): #{body['message'] || body}"
				end

				Checkout.new(
					checkout_url: body["invoice_url"],
					gateway_reference: body["id"],
					expires_at: parse_time(body["expiry_date"]),
				)
			end

			# Every Xendit callback carries the same account-wide verification token.
			def verify_callback(request)
				expected = configatron.xendit_callback_token.to_s
				given = request.headers["HTTP_X_CALLBACK_TOKEN"] || request.headers["x-callback-token"]
				return false if expected.blank? || given.blank?

				ActiveSupport::SecurityUtils.secure_compare(expected, given.to_s)
			end

			def normalize_callback(payload)
				outcome = outcome_for(payload["status"])

				attributes = {
					status_code: status_code_for(outcome),
					status_message: status_message_for(outcome, payload),
					transaction_status: transaction_status_for(outcome),
					transaction_id: payload["id"],
					gateway_reference: payload["id"],
					# The receipt renders payment_type + bank, so the broad method goes in
					# the first and the specific channel (BCA, OVO, QRIS…) in the second.
					payment_type: payload["payment_method"],
					bank: payload["payment_channel"],
					transaction_time: payload["paid_at"] || payload["updated"],
				}

				if outcome == :paid
					attributes[:paid_at] = parse_time(payload["paid_at"]) || Time.current
					attributes[:gross_amount] = (payload["paid_amount"] || payload["amount"]).to_i.to_s
				end

				Result.new(outcome: outcome, attributes: attributes)
			end

			def fetch_status(purchase)
				body = find_invoice(purchase)
				return nil if body.blank?

				normalize_callback(body)
			rescue RequestError => e
				Rails.logger.warn("[xendit] status lookup failed for #{purchase.order_id}: #{e.message}")
				nil
			end

			private

			def invoice_payload(purchase)
				user = purchase.user
				payload = {
					"external_id" => purchase.order_id.to_s,
					"amount" => purchase.gross_amount.to_i,
					"currency" => "IDR",
					"description" => purchase.productable.name.to_s,
					"invoice_duration" => invoice_duration(purchase),
					"items" => invoice_items(purchase),
					"success_redirect_url" => purchase.checkout_return_url(status: "success"),
					"failure_redirect_url" => purchase.checkout_return_url(status: "failed"),
					"metadata" => {
						"purchase_id" => purchase.id,
						"productable_type" => purchase.productable_type,
						"productable_id" => purchase.productable_id,
					},
				}

				if user.present?
					payload["payer_email"] = user.email
					payload["customer"] = {
						"given_names" => user.full_name.presence || user.email,
						"email" => user.email,
					}.compact
				end

				payload
			end

			# Xendit wants name/quantity/price; our shared item_details also carries id
			# and category, which it ignores.
			def invoice_items(purchase)
				item_details(purchase).map do |line|
					{
						"name" => line["name"].to_s.presence || purchase.productable.name.to_s,
						"quantity" => line["quantity"].to_i,
						"price" => line["price"].to_i,
					}
				end
			end

			# The gateway's countdown must match the app's remaining window, not
			# restart it — a user who clicks Pay three minutes in gets seven, not ten.
			def invoice_duration(purchase)
				purchase.checkout_window_seconds.clamp(MIN_INVOICE_DURATION, MAX_INVOICE_DURATION)
			end

			def find_invoice(purchase)
				if purchase.gateway_reference.present?
					status, body = get_json("#{base_url}/v2/invoices/#{purchase.gateway_reference}", basic_auth_user: secret_key)
					return body if status == 200
				end

				# No reference stored (the checkout call failed midway, say) — fall back
				# to the id we control.
				status, body = get_json(
					"#{base_url}/v2/invoices?external_id=#{CGI.escape(purchase.order_id.to_s)}",
					basic_auth_user: secret_key,
				)
				return nil unless status == 200

				body.is_a?(Array) ? body.first : body
			end

			def outcome_for(status)
				case status.to_s.upcase
				when "PAID", "SETTLED" then :paid
				when "EXPIRED" then :expired
				when "PENDING" then :pending
				else :failed
				end
			end

			def status_code_for(outcome)
				case outcome
				when :paid then SUCCESS_CODE
				when :expired then EXPIRED_CODE
				when :pending then PENDING_CODE
				else FAILED_CODE
				end
			end

			def transaction_status_for(outcome)
				case outcome
				when :paid then "settlement"
				when :expired then "expire"
				when :pending then "pending"
				else "failure"
				end
			end

			def status_message_for(outcome, payload)
				case outcome
				when :paid then "Success, payment received via #{payload['payment_channel'].presence || 'Xendit'}"
				when :expired then "Payment window expired"
				when :pending then "Awaiting payment"
				else "Payment failed"
				end
			end

			def parse_time(value)
				return nil if value.blank?

				Time.zone.parse(value.to_s)
			rescue ArgumentError
				nil
			end

			def base_url
				configatron.xendit_api_url.to_s.chomp("/")
			end

			def secret_key
				key = configatron.xendit_secret_key
				raise ConfigurationError, "XENDIT_SECRET_KEY is not set" if key.blank?

				key
			end
		end
	end
end
