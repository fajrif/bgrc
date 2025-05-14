Event.delete_all
puts "create all events"

# Event
_name = FFaker::Book.unique.title + " 1"
event = Event.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
event.image.attach(io: Rails.root.join("vendor/assets/images/items/event.jpg").open, filename: "event.jpg")
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
_name = FFaker::Book.unique.title + " 2"
event = Event.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
event.image.attach(io: Rails.root.join("vendor/assets/images/items/event.jpg").open, filename: "event.jpg")
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
_name = FFaker::Book.unique.title + " 3"
event = Event.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
event.image.attach(io: Rails.root.join("vendor/assets/images/items/event.jpg").open, filename: "event.jpg")
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

# Event
_name = FFaker::Book.unique.title + " 4"
event = Event.new(name: _name, short_description: FFaker::Lorem.paragraphs.join(" "), description: FFaker::Lorem.paragraphs.join(" "))
event.image.attach(io: Rails.root.join("vendor/assets/images/items/event.jpg").open, filename: "event.jpg")
event.start_date = 1.day.from_now
event.end_date = 2.day.from_now
event.sport = @sport4
event.save
Mobility.with_locale(:id) {
	event.name = _name
	event.short_description = FFaker::Lorem.paragraphs.join(" ")
	event.description = FFaker::Lorem.paragraphs.join(" ")
}
event.save
puts "Create event: #{event.name}"
