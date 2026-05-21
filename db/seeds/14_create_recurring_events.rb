EventRsvp.delete_all
RecurringEventCourt.delete_all
RecurringEvent.delete_all
puts "create recurring events"

tennis_courts = Court.joins(:sport).where(sports: { name: "Tennis" }).first(2)
padel_court   = Court.joins(:sport).where(sports: { name: "Padel" }).first

# 1. Weekly recurring — Ladies Night every Friday (Padel)
re = RecurringEvent.new(
  title: "Ladies Night",
  short_description: "A social evening for our female members. Open court time with friendly games.",
  description: "Join us every Friday evening for Ladies Night — a fun, relaxed session open to all female members and guests. Enjoy friendly rallies, social games, and a great atmosphere on the Padel court. All skill levels welcome.",
  day_of_week: 5,
  start_time: "18:00",
  end_time: "20:00",
  capacity: 20,
  active: true,
  hide: false
)
re.courts = [padel_court] if padel_court
image_path = Rails.root.join("vendor/assets/images/ladies-night.png")
if image_path.exist?
  re.image.attach(io: image_path.open, filename: "ladies-night.png")
end
re.save!
puts "Created recurring event: #{re.title}"

# 2. One-time event — Member Open Tournament (Tennis)
re2 = RecurringEvent.new(
  title: "Member Open Tournament",
  short_description: "Annual member tournament open to all skill levels.",
  description: "Our annual Member Open Tournament welcomes players of all skill levels for a day of competitive tennis in a friendly, social environment. Singles and doubles draws available. Registration required — limited spots.",
  specific_date: Date.today + 30.days,
  start_time: "08:00",
  end_time: "17:00",
  capacity: 0,
  active: true,
  hide: false
)
re2.courts = tennis_courts if tennis_courts.any?
image_path = Rails.root.join("vendor/assets/images/open-tournament.png")
if image_path.exist?
  re2.image.attach(io: image_path.open, filename: "open-tournament.png")
end
re2.save!
puts "Created recurring event: #{re2.title}"
