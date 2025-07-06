Event.delete_all
puts "create all events"

# Event
_name = FFaker::Book.unique.title
event = Event.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
event.image.attach(io: Rails.root.join("vendor/assets/images/images/image-1.png").open, filename: "image-1.png")
event.start_date = Date.current
event.end_date = 1.day.from_now
event.sport = @sport1
event.save
Mobility.with_locale(:id) {
	event.name = _name
	event.short_description = FFaker::Lorem.paragraphs.join(" ")
	event.description = FFaker::Lorem.paragraphs.join(" ")
}
event.save
puts "Create event: #{event.name}"

# Event
_name = FFaker::Book.unique.title
event = Event.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
event.image.attach(io: Rails.root.join("vendor/assets/images/images/image-2.png").open, filename: "image-2.png")
event.start_date = Date.current
event.end_date = 2.day.from_now
event.sport = @sport1
event.save
Mobility.with_locale(:id) {
	event.name = _name
	event.short_description = FFaker::Lorem.paragraphs.join(" ")
	event.description = FFaker::Lorem.paragraphs.join(" ")
}
event.save
puts "Create event: #{event.name}"

# Event
_name = FFaker::Book.unique.title
event = Event.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
event.image.attach(io: Rails.root.join("vendor/assets/images/images/image-3.png").open, filename: "image-3.png")
event.start_date = Date.current
event.end_date = 1.day.from_now
event.sport = @sport2
event.save
Mobility.with_locale(:id) {
	event.name = _name
	event.short_description = FFaker::Lorem.paragraphs.join(" ")
	event.description = FFaker::Lorem.paragraphs.join(" ")
}
event.save
puts "Create event: #{event.name}"
