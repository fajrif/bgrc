class Sport < ApplicationRecord
	include OrderedImages

	extend Mobility
  translates :short_description, :description

	extend FriendlyId
  friendly_id :name, use: :slugged

	default_scope { order(id: :asc) }

	has_one_attached :image, dependent: :purge
	has_many_attached :images, dependent: :purge
  has_many :events
  has_many :promos
  has_many :courts

	validates_presence_of :name, :short_description, :description
	validates_uniqueness_of :name

	def should_generate_new_friendly_id?
		self.name_changed?
	end

	# golf is sold as tee times on its own booking page, not as court bookings
	def golf?
		slug.to_s == "golf" || name.to_s.strip.casecmp?("golf")
	end

	# Public rate cards, one per court type per pricing window — e.g.
	# "Outdoor Day Rate" / "Outdoor Evening Rate". Costs are keyed by day of
	# week but seeded identically across the week, so a single representative
	# day describes the whole schedule. Falls back to the court's flat hourly
	# price when an admin has entered no Cost rows.
	def rate_cards
		return [] if golf?

		courts.includes(:court_type, :costs, :business_hours).group_by { |c| c.court_type&.name }.filter_map do |type_name, type_courts|
			next if type_name.blank?
			court = type_courts.min_by(&:price)
			windows = court.costs.select { |cost| cost.day_code == representative_day_code(court) }

			if windows.any?
				windows.sort_by { |cost| cost.start_time }.map do |cost|
					rate_card(court, "#{type_name} #{band_label(cost.start_time)} Rate", cost.start_time, cost.end_time, cost.price)
				end
			else
				hours = court.business_hours.first
				[rate_card(court, "#{type_name} Rate", hours&.open || "06:00", hours&.close || "22:00", court.price)]
			end
		end.flatten
	end

	private

	def representative_day_code(court)
		codes = court.costs.map(&:day_code)
		codes.include?(1) ? 1 : codes.min
	end

	# Before noon reads as the day rate, anything later as the evening rate.
	def band_label(start_time)
		Time.parse(start_time).hour < 12 ? "Day" : "Evening"
	end

	def rate_card(court, name, start_time, end_time, price)
		{
			name: name,
			time: "#{Time.parse(start_time).strftime('%I:%M %p')} – #{Time.parse(end_time).strftime('%I:%M %p')}",
			duration: "#{court.min_duration} #{'hour'.pluralize(court.min_duration)}",
			price: court.total_price(price)
		}
	end
end
