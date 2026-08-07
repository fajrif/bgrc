puts "create all testimonials"

testimonials = [
	{ name: "Wayan Kertha", email: "wayan.kertha@example.com", company_name: "Member since 2021",
		comment: "The course at Tuban is the reason I joined, but the coaching team on the tennis side is why I stayed. Booking a tee time or a court takes thirty seconds on the app." },
	{ name: "Sarah Whitfield", email: "sarah.whitfield@example.com", company_name: "Member since 2022",
		comment: "We host our company's quarterly golf day here every year. The events team handles everything from tee times to catering, and our clients always ask where we're playing next." },
	{ name: "Made Suryani", email: "made.suryani@example.com", company_name: "Member since 2023",
		comment: "I come for the padel and stay for the spa afterwards. The recovery room after a hard-fought match is honestly half the reason I keep coming back on weekends." },
	{ name: "James Halloway", email: "james.halloway@example.com", company_name: "Guest, The Paddock",
		comment: "Booked a table at The Paddock on a whim during our stay in Nusa Dua and ended up coming back twice more that week. Great food, better view." },
	{ name: "Putu Ayu Lestari", email: "putu.ayulestari@example.com", company_name: "Member since 2020",
		comment: "My daughter started in the junior tennis program at eight years old and hasn't missed a Saturday since. The coaches genuinely know every kid by name." },
	{ name: "Robert Chen", email: "robert.chen@example.com", company_name: "Member since 2019",
		comment: "Pickleball wasn't even on my radar until a friend dragged me along. Four courts, real coaching, and a social scene that beats most clubs twice the price." },
	{ name: "Kadek Wirawan", email: "kadek.wirawan@example.com", company_name: "Member since 2022",
		comment: "The gym floor never feels crowded, even at 6pm. Between that, the pool, and yoga in the morning, it's the only membership I actually use every week." },
	{ name: "Emily Torres", email: "emily.torres@example.com", company_name: "Wedding client, 2024",
		comment: "We got married on the lawn overlooking the course last year. The events team turned our vision into reality without a single hiccup on the day." },
	{ name: "Gede Arta Wijaya", email: "gede.artawijaya@example.com", company_name: "Member since 2021",
		comment: "Twenty years of playing golf around Bali and this is still the best-maintained course I've teed off on. Green fees are fair for what you get." },
	{ name: "Michael Andersen", email: "michael.andersen@example.com", company_name: "Corporate client",
		comment: "Ran a two-day offsite here for our regional team — golf on day one, padel tournament on day two. Staff handled thirty guests without breaking a sweat." }
]

testimonials.each do |t|
	testimonial = Testimonial.find_or_initialize_by(email: t[:email])
	testimonial.assign_attributes(name: t[:name], company_name: t[:company_name], comment: t[:comment])
	testimonial.save!
	puts "Testimonial: #{testimonial.name}"
end

# Earlier runs of this seed used to `delete_all` then insert random FFaker
# gibberish on every run. Now that it upserts real, curated testimonials by
# email instead, remove any leftover FFaker rows from before this rewrite.
removed = Testimonial.where.not(email: testimonials.map { |t| t[:email] }).destroy_all
puts "Removed #{removed.size} stale testimonial(s)" if removed.any?
