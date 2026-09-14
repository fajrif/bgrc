module Api
	# Keeps an open payment page in step with the server: the countdown re-syncs from here when the
	# tab comes back into view, and a payment confirmed by webhook shows up without a manual refresh.
	class PaymentStatusesController < BaseController
		def show
			record = find_payable!
			return render_error("Not found.", status: :not_found) unless can_view_payable?(record)

			render json: { status: record.payable_status, seconds_remaining: record.time_remaining }
		end
	end
end
