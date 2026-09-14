module Api
	# What the booking calendar shows for one court: its opening hours and every hour already taken.
	class CourtsController < BaseController
		MAX_RANGE_DAYS = 31

		def availability
			court = Court.find(params[:id])
			from = Date.iso8601(params[:start].to_s)
			to = Date.iso8601(params[:end].to_s)
			if to <= from || (to - from) > MAX_RANGE_DAYS
				return render_error("Please choose a shorter date range.")
			end

			render json: CourtAvailability.new(court, from: from, to: to)
		rescue Date::Error
			render_error("Please choose a valid date range.")
		end
	end
end
