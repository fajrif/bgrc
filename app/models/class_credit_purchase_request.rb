# One visitor's intended class purchase — a pack, a party size and, for a prescheduled class, one of its
# upcoming sessions — validated and priced the way it will be saved. The class page's prices come from
# the same class methods (GroupClassBookingHelper), so the total shown is the total charged; the browser
# only ever says which options were chosen.
class ClassCreditPurchaseRequest
	include ActiveModel::Validations

	FULL_MESSAGE = "Sorry, that session no longer has room for your group. Please choose another session.".freeze

	attr_reader :group_class, :sessions_count, :pax, :session_start

	validate :choices_must_be_offered

	# A pack's price covers the whole pack, whatever the party size; without packs, each session is
	# charged at the class's price for that many people.
	def self.price_for(group_class, sessions_count:, pax:)
		pack = group_class.group_class_packs.find { |option| option.sessions_count == sessions_count }
		pack ? pack.price : group_class.check_price(pax, false) * sessions_count
	end

	# The packs a class sells, or the single count a class without packs has always sold.
	def self.pack_options(group_class)
		packs = group_class.group_class_packs.to_a
		if packs.any?
			packs.map { |pack| { sessions: pack.sessions_count, label: pack.display_label, validity: pack.validity_label } }
		else
			count = [group_class.min_pack_sessions.to_i, 1].max
			[{ sessions: count, label: count == 1 ? "Single Session" : "Pack of #{count} Sessions", validity: group_class.validity_label }]
		end
	end

	def self.pax_range(group_class)
		min = [group_class.min_pax.to_i, 1].max
		min..[group_class.max_pax.to_i, min].max
	end

	# Upcoming sessions of a prescheduled class with the places left in each. `start` is wall-clock
	# "YYYY-MM-DD HH:MM", the value sent back when buying.
	def self.sessions_for(group_class)
		group_class.upcoming_sessions.map do |session|
			{
				start: "#{session[:date].iso8601} #{session[:start_time]}",
				dateLabel: session[:date_label],
				startTime: session[:start_time],
				endTime: session[:end_time],
				placesLeft: session[:slots_remaining],
			}
		end
	end

	def initialize(group_class:, sessions_count:, pax:, session_start: nil)
		@group_class = group_class
		@sessions_count = sessions_count.to_i
		@pax = pax.to_i
		@session_start = (DateTime.strptime(session_start.to_s, "%Y-%m-%d %H:%M") rescue nil)
	end

	def total
		self.class.price_for(group_class, sessions_count: sessions_count, pax: pax)
	end

	# Creates the unpaid purchase, or returns nil if the session filled up first. For a prescheduled
	# class the places are counted and taken under a lock on the class, so two buyers cannot both get
	# the last one; an unpaid purchase keeps its places until its payment deadline.
	def purchase!(user:)
		ClassCreditPurchase.transaction do
			if group_class.is_prescheduled?
				group_class.lock!
				raise ActiveRecord::Rollback if group_class.slots_remaining_for(session_start.to_date) < pax
			end

			ClassCreditPurchase.create!(
				user: user,
				group_class: group_class,
				sessions_count: sessions_count,
				price_paid: total,
				purchase_date: Time.current,
				status: ClassCreditPurchase::PENDING,
				initial_session_date: (session_start if group_class.is_prescheduled?),
				pax: pax,
			)
		end
	end

	private

	def choices_must_be_offered
		range = self.class.pax_range(group_class)

		if self.class.pack_options(group_class).none? { |option| option[:sessions] == sessions_count }
			errors.add(:base, "Please choose one of this class's packs.")
		elsif !range.cover?(pax)
			errors.add(:base, "Please choose between #{range.first} and #{range.last} people.")
		elsif group_class.is_prescheduled? && session_start.nil?
			errors.add(:base, "Please choose one of the upcoming sessions.")
		elsif group_class.is_prescheduled? && !upcoming_session?
			errors.add(:base, "That session is no longer open for registration. Please choose another session.")
		end
	end

	def upcoming_session?
		wanted = session_start.strftime("%Y-%m-%d %H:%M")
		self.class.sessions_for(group_class).any? { |session| session[:start] == wanted }
	end
end
