# One paid class credit being spent on a session: a court of the class's sport, one of its coaches and
# an hour on the court's calendar. Api::ClassSessionClaimsController books it. The session was paid for
# with the credit, so there is no quote and no payment window.
class ClassSessionClaim
	include ActiveModel::Validations

	HORIZON = CourtBookingRequest::BOOKING_HORIZON
	UNAVAILABLE_MESSAGE = CourtBookingRequest::UNAVAILABLE_MESSAGE
	NO_CREDIT_MESSAGE = "No sessions remaining or credit is invalid.".freeze

	attr_reader :credit_purchase, :court, :coach, :start, :failure_message

	validate :claim_must_be_allowed

	def self.courts_for(group_class)
		group_class.sport ? group_class.sport.courts : Court.none
	end

	# Coaches who teach the class's sport. Unassigned coaches stay available, so an existing coach
	# without a sport is never hidden.
	def self.coaches_for(group_class)
		group_class.sport ? Coach.where(sport_id: [group_class.sport_id, nil]) : Coach.all
	end

	# `start` is wall-clock "YYYY-MM-DD HH:MM". Courts and coaches outside the class's sport are ignored.
	def initialize(credit_purchase:, court_id:, coach_id:, start:)
		@credit_purchase = credit_purchase
		@court = self.class.courts_for(group_class).find_by(id: court_id)
		@coach = self.class.coaches_for(group_class).find_by(id: coach_id)
		@start = (DateTime.strptime(start.to_s, "%Y-%m-%d %H:%M") rescue nil)
	end

	def group_class
		credit_purchase.group_class
	end

	def duration
		group_class.min_duration.to_i
	end

	# Books the session, or returns nil with `failure_message` set. The credit and the court are both
	# locked, so the last credit cannot be spent twice and two claims cannot take the same hour.
	def claim!(user:)
		Booking.transaction do
			credit_purchase.lock!
			fail_with!(NO_CREDIT_MESSAGE) unless credit_purchase.valid_credit?
			court.lock!
			fail_with!(UNAVAILABLE_MESSAGE) unless Booking.check_available_dates?(court.id, start.strftime("%d/%m/%Y %H:%M"), duration)

			Booking.create!(
				user: user,
				court: court,
				coach: coach,
				group_class: group_class,
				class_credit_purchase: credit_purchase,
				date: start,
				end_date: start + duration.hours,
				duration: duration,
				pax: credit_purchase.pax,
				court_type: Booking::WITH_COACH,
				status: Booking::PAID,
				price: 0,
				price_coach: 0,
				total_price: 0,
			)
		end
	end

	private

	def fail_with!(message)
		@failure_message = message
		raise ActiveRecord::Rollback
	end

	def claim_must_be_allowed
		if group_class.is_prescheduled?
			errors.add(:base, "Prescheduled classes are booked from the class page.")
		elsif !credit_purchase.valid_credit?
			errors.add(:base, NO_CREDIT_MESSAGE)
		elsif court.nil?
			errors.add(:base, "Please choose a court.")
		elsif start.nil?
			errors.add(:base, "Please select a time slot on the calendar.")
		elsif start.minute != 0
			errors.add(:base, "Sessions start on the hour.")
		elsif start < ClubTime.now
			errors.add(:base, "Cannot book a time slot in the past.")
		elsif start > ClubTime.now + HORIZON
			errors.add(:base, "Sessions can only be booked up to 14 days in advance.")
		elsif start + duration.hours > (start.to_date + 1).to_datetime
			errors.add(:base, "A session must end on the day it starts.")
		elsif coach.nil?
			errors.add(:base, "Please choose a coach.")
		end
	end
end
