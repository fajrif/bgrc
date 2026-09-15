module LateRescheduleHelper
	# The reschedule page for an order waiting for a new time, or nil when it isn't waiting.
	def late_reschedule_path_for(record)
		pending = case record
		          when Booking, GolfReservation then record.needs_reschedule?
		          when ClassCreditPurchase then record.group_class_registrations.exists?(status: GroupClassRegistration::NEEDS_RESCHEDULE)
		          end
		return unless pending

		type, order_id = LateReschedule.address(record)
		users_late_reschedule_path(type: type, id: order_id)
	end

	# [component name, props] for the picker on users/late_reschedules#show (app/frontend/components/reschedule).
	def late_reschedule_app(record)
		type, order_id = LateReschedule.address(record)
		reschedule_url = api_late_reschedule_path(type: type, id: order_id)

		case record
		when Booking
			courts = LateReschedule::CourtBooking.courts_for(record).to_a
			["CourtRescheduleApp", {
				courts: courts.map { |court| { id: court.id, name: court.name } },
				initialCourtId: courts.find { |court| court.id == record.court_id }&.id || courts.first&.id,
				durationHours: record.duration,
				durationLabel: record.duration_label,
				today: ClubTime.today.iso8601,
				maxDate: (ClubTime.today + LateReschedule::CourtBooking::HORIZON).iso8601,
				urls: { availability: api_court_availability_path(id: "__COURT__"), reschedule: reschedule_url },
			}]
		when GolfReservation
			["TeeTimeRescheduleApp", {
				courseName: record.golf_course.name,
				players: record.players_count,
				holesLabel: record.holes_label,
				today: ClubTime.today.iso8601,
				maxDate: (ClubTime.today + LateReschedule::TeeTime::HORIZON).iso8601,
				# Its own course, even if another course is the bookable one now.
				urls: { teeTimes: golf_tee_times_path(course_id: record.golf_course_id), reschedule: reschedule_url },
			}]
		when GroupClassRegistration
			["ClassRescheduleApp", {
				className: record.group_class.name,
				pax: record.pax,
				sessions: ClassCreditPurchaseRequest.sessions_for(record.group_class),
				urls: { sessions: api_group_class_sessions_path(id: record.group_class_id), reschedule: reschedule_url },
			}]
		end
	end
end
