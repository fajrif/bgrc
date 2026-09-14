module Api
	# Moves a late-paid booking, tee time or class session to the new time its customer chose
	# (Users::LateReschedulesController's page). Only the owner can move it, and only while it is waiting
	# for a new time.
	class LateReschedulesController < BaseController
		before_action :require_user!

		def update
			record = LateReschedule.pending_record(current_user, params[:type], params[:id])
			return render_error(LateReschedule::NOT_PENDING_MESSAGE, status: :not_found) if record.nil?

			reschedule = LateReschedule.for(record, params)
			return render_error(reschedule.errors.full_messages.first) unless reschedule.valid?
			return render_error(reschedule.failure_message, status: :conflict) unless reschedule.apply!

			reschedule.notify!
			# Shown on the page the customer goes to next.
			flash[:notice] = reschedule.confirmation_notice
			render json: { redirect_url: reschedule.redirect_path }
		end
	end
end
