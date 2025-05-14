Facility.delete_all
puts "create all facilities"

# Swimming Pool
facility = Facility.new(name: "Swimming Pool", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/swimming-pool.jpg").open, filename: "swimming-pool.jpg")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Kolam Renang"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# GYM
facility = Facility.new(name: "GYM", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/gym.jpg").open, filename: "gym.jpg")
facility.save
Mobility.with_locale(:id) {
	facility.name = "GYM"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Sauna
facility = Facility.new(name: "Sauna", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/sauna.jpg").open, filename: "sauna.jpg")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Sauna"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"

# Locker Room
facility = Facility.new(name: "Locker Room", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/facilities/locker-room.jpg").open, filename: "locker-room.jpg")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Ruang Ganti"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"
