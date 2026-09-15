module CourtBookingHelper
	# Props for CourtBookingApp (app/frontend/components/booking/CourtBookingApp.vue). Court URLs carry
	# a __COURT__ placeholder the component fills in as the visitor switches courts.
	def court_booking_props(sport:, court_types:, court_type:, court:, date:)
		{
			sport: { id: sport.id, name: sport.name },
			courtTypes: court_types.map { |type| { id: type.id, name: type.name } },
			courts: sport.courts.map { |c| { id: c.id, name: c.name, courtTypeId: c.court_type_id } },
			initialCourtTypeId: court_type&.id,
			initialCourtId: court&.id,
			initialDate: date.iso8601,
			today: ClubTime.today.iso8601,
			maxDate: (ClubTime.today + CourtBookingRequest::BOOKING_HORIZON).iso8601,
			items: Item.all.map { |item| { id: item.id, name: item.name, price: item.price.to_i } },
			urls: {
				availability: api_court_availability_path(id: "__COURT__"),
				quote: api_court_quote_path(id: "__COURT__"),
				bookings: api_court_bookings_path(id: "__COURT__"),
			},
			whatsappUrl: "https://wa.me/#{configatron.whatsapp_number.to_s.gsub(/\D/, '')}",
		}
	end
end
