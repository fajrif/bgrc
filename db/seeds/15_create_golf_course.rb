puts "Seeding golf course..."

golf_course = GolfCourse.find_or_initialize_by(name: "BGRC Golf Course")
golf_course.assign_attributes(
  location: "Bali Beach Country Club, Tuban, Bali",
  holes_available: "9,18",
  interval_minutes: 10,
  max_players: 4,
  status: GolfCourse::AVAILABLE
)
golf_course.save!

puts "  Golf course: #{golf_course.name}"

# Rates
rates = [
  { holes: 9,  day_type: :weekday, price: 350_000, label: "Weekday 9 Holes" },
  { holes: 9,  day_type: :weekend, price: 450_000, label: "Weekend 9 Holes" },
  { holes: 18, day_type: :weekday, price: 650_000, label: "Weekday 18 Holes" },
  { holes: 18, day_type: :weekend, price: 850_000, label: "Weekend 18 Holes" },
]
rates.each do |r|
  GolfRate.find_or_create_by!(golf_course: golf_course, holes: r[:holes], day_type: r[:day_type]) do |rate|
    rate.price = r[:price]
    rate.label = r[:label]
  end
end
puts "  Created #{GolfRate.count} golf rates"

# Add-on items
items = [
  { name: "Golf Cart",     price: 200_000, price_type: :flat },
  { name: "Caddie",        price: 150_000, price_type: :flat },
  { name: "Club Rental",   price: 100_000, price_type: :per_person },
  { name: "Golf Buggy",    price: 180_000, price_type: :flat },
]
items.each do |i|
  GolfItem.find_or_create_by!(golf_course: golf_course, name: i[:name]) do |item|
    item.price      = i[:price]
    item.price_type = i[:price_type]
    item.status     = :active
  end
end
puts "  Created #{GolfItem.count} golf items"

puts "Golf course seed complete."
