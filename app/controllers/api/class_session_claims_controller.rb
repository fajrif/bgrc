module Api
	# Spends one class credit on a session from the Vue calendar (ClassSessionClaimApp). Only the
	# credit's owner can claim, and only while the credit is paid, unexpired and has sessions left.
	class ClassSessionClaimsController < BaseController
		before_action :require_user!

		def create
			claim = ClassSessionClaim.new(
				credit_purchase: current_user.class_credit_purchases.find(params[:id]),
				court_id: params[:court_id],
				coach_id: params[:coach_id],
				start: params[:start],
			)
			return render_error(claim.errors.full_messages.first) unless claim.valid?

			booking = claim.claim!(user: current_user)
			return render_error(claim.failure_message, status: :conflict) if booking.nil?

			# Shown on My Bookings, where the page goes next.
			flash[:notice] = "Session claimed for #{booking.date.strftime('%a %d %b %Y, %H:%M')}. You can reschedule within 24 hours."
			render json: { redirect_url: users_bookings_path }, status: :created
		end
	end
end
