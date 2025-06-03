Promo.delete_all
puts "create all promos"

# Promo
_name = FFaker::Book.unique.title + " 1"
promo = Promo.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
promo.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-gold.png").open, filename: "banner-gold.png")
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
promo.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-gold.png").open, filename: "banner-gold.png")
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
promo.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-gold.png").open, filename: "banner-gold.png")
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
