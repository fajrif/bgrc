Promo.delete_all
puts "create all promos"

# Promo
_name = "Promo 1"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/images/image-4.png").open, filename: "image-4.png")
promo.start_date = Date.current
promo.end_date = 1.day.from_now
promo.sport = @sport1
promo.save
Mobility.with_locale(:id) {
	promo.name = _name
	promo.short_description = FFaker::Lorem.paragraphs.join(" ")
	promo.description = FFaker::Lorem.paragraphs.join(" ")
}
promo.save
puts "Create promo: #{promo.name}"

# Promo
_name = "Promo 2"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/images/image-5.png").open, filename: "image-5.png")
promo.start_date = Date.current
promo.end_date = 2.day.from_now
promo.sport = @sport1
promo.save
Mobility.with_locale(:id) {
	promo.name = _name
	promo.short_description = FFaker::Lorem.paragraphs.join(" ")
	promo.description = FFaker::Lorem.paragraphs.join(" ")
}
promo.save
puts "Create promo: #{promo.name}"

# Promo
_name = "Promo 3"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/images/image-6.png").open, filename: "image-6.png")
promo.start_date = Date.current
promo.end_date = 1.day.from_now
promo.sport = @sport2
promo.save
Mobility.with_locale(:id) {
	promo.name = _name
	promo.short_description = FFaker::Lorem.paragraphs.join(" ")
	promo.description = FFaker::Lorem.paragraphs.join(" ")
}
promo.save
puts "Create promo: #{promo.name}"
