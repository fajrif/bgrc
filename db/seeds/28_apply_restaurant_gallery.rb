# Restaurant page template (Phase 2 gap) — gallery photos for Tavara, cropped from the
# design. Idempotent: the venue's gallery is replaced, so photos an admin uploaded to
# Tavara are overwritten. Run after 19.
puts "apply restaurant gallery"

P28_PHOTOS = Rails.root.join("vendor/assets/images/new-design/photos/dining/tavara")

tavara = Restaurant.find_by("name @> ?", { en: "Tavara" }.to_json)
if tavara
	tavara.images.purge if tavara.images.attached?
	(1..6).each do |i|
		file = P28_PHOTOS.join("gallery-#{i}.jpg")
		tavara.images.attach(io: file.open, filename: "tavara-gallery-#{i}.jpg")
	end
end
