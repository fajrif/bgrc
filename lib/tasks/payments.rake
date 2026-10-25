namespace :payments do
	desc "Settle purchases the gateway completed but we never heard about. Run from cron, e.g. every 10 minutes."
	task reconcile: :environment do
		lookback = Integer(ENV.fetch("RECONCILE_LOOKBACK_DAYS", 7)).days
		reconciler = PaymentGateways::Reconciler.new(lookback: lookback, io: $stdout)
		total = reconciler.scope.count
		counts = reconciler.call

		puts "reconciled #{total} pending purchase(s): #{counts.sort.map { |k, v| "#{k}=#{v}" }.join(' ')}"
	end

	desc "Show pending gateway purchases without contacting the gateway."
	task pending: :environment do
		PaymentGateways::Reconciler.new.scope.find_each do |purchase|
			puts format("%-24s %-9s %-20s %s", purchase.order_id, purchase.payment_gateway,
			            purchase.productable_type, purchase.created_at.iso8601)
		end
	end

	desc "Show the active payment gateway, whether its keys are set, and the webhook URLs to register."
	task gateway: :environment do
		active = PaymentGateways.current_name
		base = Purchase.site_url_options
		origin = "#{base[:protocol]}://#{base[:host]}#{":#{base[:port]}" if base[:port]}"
		key_vars = {
			"xendit" => %w[XENDIT_SECRET_KEY XENDIT_CALLBACK_TOKEN],
			"midtrans" => %w[MIDTRANS_MERCHANT_ID MIDTRANS_CLIENT_KEY MIDTRANS_SERVER_KEY],
		}

		puts "Active gateway (new checkouts): #{active}"
		puts "Site URL (return URLs):         #{origin}"
		puts

		PaymentGateways::ADAPTERS.each_key do |name|
			missing = key_vars.fetch(name).select { |var| ENV[var].blank? }
			state = missing.empty? ? "keys set" : "MISSING #{missing.join(', ')}"
			puts format("%-9s %-1s %s", name, (name == active ? "*" : ""), state)
			puts "          webhook: #{origin}/webhooks/#{name}"
		end

		puts
		puts "Midtrans API: #{configatron.midtrans_api_url}"
		puts "Xendit API:   #{configatron.xendit_api_url} (#{configatron.xendit_secret_key.to_s.start_with?('xnd_production_') ? 'LIVE' : 'test'} key)"
		puts
		puts "Purchases by gateway:"
		Purchase.unscoped.group(:payment_gateway).count.sort.each do |name, count|
			puts format("  %-9s %d", name, count)
		end
	end
end
