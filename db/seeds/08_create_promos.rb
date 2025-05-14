Promo.delete_all
puts "create all promos"

# Promo
_name = FFaker::Book.unique.title + " 1"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/items/promo.jpg").open, filename: "promo.jpg")
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
_name = FFaker::Book.unique.title + " 2"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/items/promo.jpg").open, filename: "promo.jpg")
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
_name = FFaker::Book.unique.title + " 3"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/items/promo.jpg").open, filename: "promo.jpg")
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

# Promo
_name = FFaker::Book.unique.title + " 4"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/items/promo.jpg").open, filename: "promo.jpg")
promo.start_date = 1.day.from_now
promo.end_date = 2.day.from_now
promo.sport = @sport4
promo.save
Mobility.with_locale(:id) {
	promo.name = _name
	promo.short_description = FFaker::Lorem.paragraphs.join(" ")
	promo.description = FFaker::Lorem.paragraphs.join(" ")
}
promo.save
puts "Create promo: #{promo.name}"
