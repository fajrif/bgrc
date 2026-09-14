module LateReschedule
	# A prescheduled class registration moves to another upcoming session of the same class with room for
	# the whole party.
	class ClassSession < Base
		attr_reader :registration, :session_start

		validate :session_must_be_offered

		# `session_start` is wall-clock "YYYY-MM-DD HH:MM", as ClassCreditPurchaseRequest.sessions_for gives it.
		def initialize(registration, session_start:)
			@registration = registration
			@session_start = self.class.parse_time(session_start)
		end

		def group_class
			registration.group_class
		end

		def apply!
			moved = GroupClassRegistration.transaction do
				group_class.lock!
				registration.lock!
				fail_with!(ALREADY_MOVED_MESSAGE) unless registration.needs_reschedule?
				if group_class.slots_remaining_for(session_start.to_date) < registration.pax
					fail_with!(ClassCreditPurchaseRequest::FULL_MESSAGE)
				end

				registration.update!(session_date: session_start, status: GroupClassRegistration::REGISTERED)
			end
			!!moved
		end

		# Class sessions have no confirmation email; the purchase page shows the registration.

		def confirmation_notice
			"You are registered for #{session_start.strftime('%A, %d %b %Y, %H:%M')}."
		end

		def redirect_path
			routes.class_credit_purchase_path(id: registration.class_credit_purchase_id)
		end

		private

		def session_must_be_offered
			if session_start.nil?
				errors.add(:base, "Please choose one of the upcoming sessions.")
			elsif ClassCreditPurchaseRequest.sessions_for(group_class).none? { |session| session[:start] == session_start.strftime("%Y-%m-%d %H:%M") }
				errors.add(:base, "That session is no longer open for registration. Please choose another session.")
			end
		end
	end
end
