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
end
