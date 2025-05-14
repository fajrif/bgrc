require 'net/http'
require 'uri'
require 'json'
require "base64"

class ApiMidtrans

	def self.request_token(purchase)
		uri = URI.parse(configatron.midtrans_api_url)
		json = JSON.dump({
			"transaction_details" => {
				"order_id" => purchase.order_id.to_s,
				"gross_amount" => purchase.gross_amount.to_i
			},
			"item_details" => [{
				"id" => purchase.productable.id.to_s,
				"price" => purchase.gross_amount.to_i,
				"quantity" => 1,
				"name" => purchase.productable.name,
				"category" => purchase.productable_type.to_s,
				"merchant_name" => "Flex"
			}],
			"customer_details" => {
				"first_name" => purchase.user.full_name,
				"email" => purchase.user.email
			},
			"credit_card" => {
				"secure" => true,
				"save_card" => true,
				"save_token_id" => true
			}
		})

		request = Net::HTTP::Post.new(uri)
		request.content_type = "application/json"
		request["Accept"] = "application/json"
		request.basic_auth configatron.midtrans_server_key, ''
		request["Cache-Control"] = "no-cache"
		request["Connection"] = "keep-alive"
		request.body = json

		req_options = {
			use_ssl: uri.scheme == "https",
		}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
			http.request(request)
		end

		if response.code == "201"
			token = JSON.parse(response.body)["token"]
			return token
		else
			Rails.logger.warn "Response Code: #{response.code}"
			Rails.logger.warn "Response Body: #{JSON.parse(response.body)}"
			return nil
		end
	rescue StandardError => e
		Rails.logger.error "message: #{e.message}"
		return nil
	end

end
