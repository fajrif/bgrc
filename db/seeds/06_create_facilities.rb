Facility.delete_all
puts "create all facilities"

# Swimming Pool
facility = Facility.new(name: "Swimming Pool", short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
facility.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
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
facility.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
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
facility.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
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
facility.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
facility.save
Mobility.with_locale(:id) {
	facility.name = "Ruang Ganti"
	facility.short_description = FFaker::Lorem.paragraphs.join(" ")
	facility.description = FFaker::Lorem.paragraphs.join(" ")
}
facility.save
puts "Create facility: #{facility.name}"
