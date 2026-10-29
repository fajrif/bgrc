# Design photography for the Phase 1, 2 and 4 pages. The photos are cropped from the
# mockups into vendor/assets/images/new-design/photos. Idempotent: every attachment
# listed here is replaced, so run it again after a crop changes. Images an admin
# uploaded to the records below are overwritten.
puts "apply design photos"

P26 = Rails.root.join("vendor/assets/images/new-design/photos")

def p26_file(path) = P26.join("#{path}.jpg").open

def p26_one(record, attachment, path)
	return if record.nil?
	record.public_send(attachment).purge if record.public_send(attachment).attached?
	record.public_send(attachment).attach(io: p26_file(path), filename: "#{path.tr('/', '-')}.jpg")
end

def p26_many(record, attachment, paths)
	return if record.nil?
	record.public_send(attachment).purge if record.public_send(attachment).attached?
	paths.each { |path| record.public_send(attachment).attach(io: p26_file(path), filename: "#{path.tr('/', '-')}.jpg") }
	record.normalize_image_positions! if attachment == :images && record.respond_to?(:normalize_image_positions!)
end

def p26_facility(en_name) = Facility.find_by("name @> ?", { en: en_name }.to_json)

# --- Golf: root cards, shared gallery, Golf Lessons classes, Driving Range pricing ---
golf_gallery = (1..6).map { |i| "golf/gallery-#{i}" }
p26_one(p26_facility("Golf Course"), :image, "golf/card-1")
p26_one(p26_facility("Golf Lessons & Academy"), :image, "golf/card-2")
p26_one(p26_facility("Driving Range"), :image, "golf/card-3")
p26_many(Sport.find_by(name: "Golf"), :images, golf_gallery)
%w[Golf\ Lessons\ &\ Academy Driving\ Range].each { |name| p26_many(p26_facility(name), :images, golf_gallery) }

lessons = p26_facility("Golf Lessons & Academy")
lessons&.treatments&.order(:position)&.each_with_index { |t, i| p26_one(t, :image, "lessons/class-#{i + 1}") if i < 4 }
range = p26_facility("Driving Range")
range&.facility_rates&.order(:position)&.each_with_index { |r, i| p26_one(r, :image, "range/pricing-#{i + 1}") if i < 4 }

# --- Racquet Sports: root cards, galleries, pricing, facilities, coaches ---
%w[Tennis Padel Pickleball].each_with_index do |name, index|
	key = name.downcase
	p26_one(p26_facility(name), :image, "racquet/card-#{index + 1}")
	sport = Sport.find_by(name: name)
	p26_many(sport, :images, (1..6).map { |i| "#{key}/gallery-#{i}" })
	p26_many(sport, :pricing_images, (1..(key == "tennis" ? 4 : 2)).map { |i| "#{key}/pricing-#{i}" })
end

extra_amenities = {
	"Padel" => [
		["Padel Coaching Court", "Pelatihan Padel", "Private and group padel coaching with MITS Academy coaches."],
		["Padel Social Corner", "Sudut Sosial Padel", "A relaxed spot to cool down and swap rallies after a match."]
	],
	"Pickleball" => [
		["Pickleball Beginner Courts", "Lapangan Pemula Pickleball", "Gentle courts for first-timers learning the rules and the kitchen line."],
		["Pickleball Social Play", "Bermain Santai Pickleball", "Open play sessions that mix levels and keep the games moving."]
	]
}
%w[Tennis Padel Pickleball].each do |name|
	facility = p26_facility(name)
	next unless facility
	(extra_amenities[name] || []).each_with_index do |(en, id, desc), index|
		next if Amenity.where(facility_id: facility.id).find_by("name @> ?", { en: en }.to_json)
		amenity = Amenity.new(facility: facility, position: facility.amenities.count + index + 1, name: en, short_description: desc)
		amenity.image.attach(io: p26_file("#{name.downcase}/fac-#{facility.amenities.count + 1}"), filename: "#{name.downcase}-fac.jpg")
		amenity.save!
		Mobility.with_locale(:id) { amenity.name = id; amenity.short_description = desc; amenity.save! }
	end
	facility.amenities.order(:position).each_with_index { |a, i| p26_one(a, :image, "#{name.downcase}/fac-#{i + 1}") if i < 5 }
end

coach_photos = {
	"Golf" => %w[team/1 team/2 team/3],
	"Tennis" => %w[tennis/coach-1 tennis/coach-2 tennis/coach-3],
	"Padel" => %w[padel/coach-1 padel/coach-2 padel/coach-3],
	"Pickleball" => %w[pickleball/coach-1 pickleball/coach-2 pickleball/coach-3]
}
coach_photos.each do |sport_name, photos|
	Coach.where(sport_id: Sport.where(name: sport_name).select(:id)).order(:id).each_with_index do |coach, i|
		p26_one(coach, :photo, photos[i % photos.size])
	end
end

# --- Beach Club gallery ---
p26_many(p26_facility("Beach Club"), :images, (1..6).map { |i| "beach/gallery-#{i}" })

# --- About, team, dining, events ---
TeamMember.where.not(department: "fitness").order(:id).each_with_index do |member, i|
	p26_one(member, :photo, "team/#{(i % 9) + 1}")
end

dining = { "The Paddock" => ["Tavara", "dining/1"], "Kasumi" => ["Kasumi", "dining/2"], "Pit Lane" => ["Corsa", "dining/3"],
					 "Mezzaluna" => ["Mezzaluna", "dining/4"], "Porto" => ["Porto", "dining/5"] }
Restaurant.all.each do |restaurant|
	en_name = Mobility.with_locale(:en) { restaurant.name }
	if (entry = dining[en_name])
		# the design's photos carry the venue names, so the venue takes the design's name
		restaurant.update_columns(name: { "en" => entry[0], "id" => entry[0] }) if entry[0] != en_name
		p26_one(restaurant, :image, entry[1])
	elsif en_name == "Grab & Go"
		p26_one(restaurant, :image, "grab/banner")
		p26_one(restaurant, :banner, "grab/banner")
	end
end

{ "Weddings" => "events/type-1", "Corporate Events" => "events/type-2", "Private Celebrations" => "events/type-3" }.each do |name, path|
	type = EventType.all.find { |t| Mobility.with_locale(:en) { t.name } == name }
	p26_one(type, :image, path)
end
wedding = EventType.all.find { |t| Mobility.with_locale(:en) { t.name } == "Weddings" }
p26_one(wedding, :banner, "events/wedding-hero")
p26_many(wedding, :images, (1..6).map { |i| "events/wedding-gallery-#{i}" })

puts "design photos applied"
