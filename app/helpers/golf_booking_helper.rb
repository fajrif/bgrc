module GolfBookingHelper
	# Props for GolfBookingApp (app/frontend/components/golf/GolfBookingApp.vue), for the bookable course.
	def golf_booking_props(course)
		{
			course: {
				id: course.id,
				name: course.name,
				holesList: course.holes_list,
				maxPlayers: [course.max_players.to_i, GolfReservationRequest::MAX_PLAYERS].min,
			},
			today: ClubTime.today.iso8601,
			maxDate: (ClubTime.today + GolfReservationRequest::BOOKING_HORIZON).iso8601,
			items: course.golf_items.active.order(:name).map do |item|
				{ id: item.id, name: item.name, price: item.price.to_i, perPerson: item.per_person? }
			end,
			urls: {
				teeTimes: golf_tee_times_path(course_id: course.id),
				quote: api_golf_quote_path,
				reservations: api_golf_reservations_path,
			},
		}
	end
end
