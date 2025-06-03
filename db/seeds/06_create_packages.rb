Package.delete_all
puts "create all packages"

# Package
_name = FFaker::Book.unique.title + " 1"
package = Package.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
package.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
package.start_date = Date.current
package.end_date = 1.day.from_now
package.sport = @sport1
package.save
Mobility.with_locale(:id) {
	package.name = _name
	package.short_description = FFaker::Lorem.paragraphs.join(" ")
	package.description = FFaker::Lorem.paragraphs.join(" ")
}
package.save
puts "Create package: #{package.name}"

# Package
_name = FFaker::Book.unique.title + " 2"
package = Package.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
package.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
package.start_date = Date.current
package.end_date = 2.day.from_now
package.sport = @sport1
package.save
Mobility.with_locale(:id) {
	package.name = _name
	package.short_description = FFaker::Lorem.paragraphs.join(" ")
	package.description = FFaker::Lorem.paragraphs.join(" ")
}
package.save
puts "Create package: #{package.name}"

# Package
_name = FFaker::Book.unique.title + " 3"
package = Package.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
package.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
package.start_date = Date.current
package.end_date = 1.day.from_now
package.sport = @sport2
package.save
Mobility.with_locale(:id) {
	package.name = _name
	package.short_description = FFaker::Lorem.paragraphs.join(" ")
	package.description = FFaker::Lorem.paragraphs.join(" ")
}
package.save
puts "Create package: #{package.name}"

# Package
_name = FFaker::Book.unique.title + " 4"
package = Package.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
package.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-grey.png").open, filename: "banner-grey.png")
package.start_date = 1.day.from_now
package.end_date = 2.day.from_now
package.sport = @sport4
package.save
Mobility.with_locale(:id) {
	package.name = _name
	package.short_description = FFaker::Lorem.paragraphs.join(" ")
	package.description = FFaker::Lorem.paragraphs.join(" ")
}
package.save
puts "Create package: #{package.name}"
