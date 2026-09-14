module LateReschedule
	# What the three kinds of move share. Each subclass validates the chosen time, then `apply!` takes it
	# under a lock (returning false with `failure_message` if it was lost), `notify!` sends the usual
	# confirmation, and `confirmation_notice` / `redirect_path` say where the customer goes next.
	class Base
		include ActiveModel::Validations

		attr_reader :failure_message

		# Wall-clock "YYYY-MM-DD HH:MM", as the booking pages send it.
		def self.parse_time(value)
			DateTime.strptime(value.to_s, "%Y-%m-%d %H:%M")
		rescue ArgumentError
			nil
		end

		def notify!; end

		private

		def fail_with!(message)
			@failure_message = message
			raise ActiveRecord::Rollback
		end

		def routes
			Rails.application.routes.url_helpers
		end
	end
end
