Facility.delete_all
puts "create all facilities"

# Golf Course
facility = Facility.new(name: "Golf Course", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/golf-course.png").open, filename: "golf-course.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Lapangan Golf"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Tennis Court
facility = Facility.new(name: "Tennis Court", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/tennis-court.png").open, filename: "tennis-court.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Lapangan Tenis"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Padel Court
facility = Facility.new(name: "Padel Court", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/padel-court.png").open, filename: "padel-court.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Lapangan Padel"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Pickleball Court
facility = Facility.new(name: "Pickleball Court", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/pickleball-court.png").open, filename: "pickleball-court.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Lapangan Pickleball"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# GYM
facility = Facility.new(name: "GYM", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/gym.png").open, filename: "gym.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "GYM"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Swimming Pool
facility = Facility.new(name: "Swimming Pool", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/swimming-pool.png").open, filename: "swimming-pool.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Kolam Renang"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Yoga
facility = Facility.new(name: "Yoga", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/yoga.png").open, filename: "yoga.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Yoga"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Pilates
facility = Facility.new(name: "Pilates", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/pilates.png").open, filename: "pilates.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Pilates"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Restaurant
facility = Facility.new(name: "Restaurant", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/restaurant.png").open, filename: "restaurant.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Restoran"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Pro Shop
facility = Facility.new(name: "Pro Shop", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/pro-shop.png").open, filename: "pro-shop.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Toko Alat"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Recovery Center
facility = Facility.new(name: "Sauna", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/recovery-center.png").open, filename: "recovery-center.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Pusat Rehabillitasi"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Locker Room
facility = Facility.new(name: "Locker Room", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/lockers.png").open, filename: "lockers.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Ruang Ganti"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"
