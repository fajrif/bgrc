# Phase 6 — Spa + Wellness redesign: tab names and page headings, banners, cropped
# design photography and the operating hours every child page now shows. Idempotent:
# attachments listed here are replaced, so images an admin uploaded to these records
# are overwritten. Run after 16 and 23.
puts "apply spa phase 6"

P27_PHOTOS  = Rails.root.join("vendor/assets/images/new-design/photos/spa")
P27_BANNERS = Rails.root.join("vendor/assets/images/new-design/club-life/spa")

def p27_attach(record, attachment, file)
	return if record.nil?
	record.public_send(attachment).purge if record.public_send(attachment).attached?
	record.public_send(attachment).attach(io: file.open, filename: file.basename.to_s)
end

def p27_photo(name) = P27_PHOTOS.join("#{name}.jpg")

def p27_facility(*en_names)
	en_names.each do |en|
		found = Facility.find_by("name @> ?", { en: en }.to_json)
		return found if found
	end
	nil
end

root     = p27_facility("Spa + Wellness")
spa      = p27_facility("Spa")
recovery = p27_facility("Recovery Center", "Recovery")
anti     = p27_facility("Anti-Aging", "Anti Aging")

# Tabs read "Recovery Center" / "Anti-Aging"; the page and its card read "Reverie ...".
# update_columns keeps the slugs, so the URLs do not move.
recovery&.update_columns(name: { "en" => "Recovery Center", "id" => "Pusat Pemulihan" })
anti&.update_columns(name: { "en" => "Anti-Aging", "id" => "Anti-Aging" })
{ recovery => ["Reverie Recovery", "Reverie Recovery"],
	anti => ["Reverie Medical Wellness", "Reverie Medical Wellness"] }.each do |facility, (en, id)|
	facility&.update_columns(page_heading: { "en" => en, "id" => id })
end

# Tab order in the design: Golf, Racquet, Fitness, Spa & Wellness, Beach Club.
beach = p27_facility("Beach Club")
if root && beach
	root.update_columns(position: 4)
	beach.update_columns(position: 5)
end

# --- Root: caption under the wide photo, CTA, card photos, gallery ---
if root
	root.facilities_intro = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
	root.cta_label = "Visit BBCC Spa & Wellness"
	root.save!
	Mobility.with_locale(:id) { root.cta_label = "Kunjungi BBCC Spa & Wellness"; root.save! }
	p27_attach(root, :middle_banner, p27_photo("root-wide"))
	root.images.purge if root.images.attached?
	(1..6).each { |i| root.images.attach(io: p27_photo("root-gallery-#{i}").open, filename: "spa-gallery-#{i}.jpg") }
	root.normalize_image_positions! if root.respond_to?(:normalize_image_positions!)
end

# --- Children: banner, card photo, CTA, operating hours ---
hours = {
	en: "Monday – Friday: 06:00 AM – 06:00 PM\nSaturday – Sunday: 05:30 AM – 06:30 PM\nPublic Holidays: 05:30 AM – 06:30 PM",
	id: "Senin – Jumat: 06.00 – 18.00\nSabtu – Minggu: 05.30 – 18.30\nHari Libur Nasional: 05.30 – 18.30"
}
[
	[spa, "banner-spa", "root-service-1", "Book Spa Now", "Pesan Spa Sekarang"],
	[recovery, "banner-recovery", "root-service-2", "Book Recovery Now", "Pesan Pemulihan Sekarang"],
	[anti, "banner-anti-aging", "root-service-3", "Book Anti-Aging Now", "Pesan Anti-Aging Sekarang"]
].each do |facility, banner, card, cta_en, cta_id|
	next unless facility
	p27_attach(facility, :banner, P27_BANNERS.join("#{banner}.jpg"))
	p27_attach(facility, :image, p27_photo(card))
	facility.cta_label = cta_en
	facility.save!
	Mobility.with_locale(:id) { facility.cta_label = cta_id; facility.save! }

	detail = FacilityDetail.where(facility_id: facility.id).find_by("title @> ?", { en: "Operating Hours" }.to_json) ||
					 FacilityDetail.new(facility: facility)
	detail.facility = facility
	detail.position = 1
	detail.title = "Operating Hours"
	detail.body = hours[:en]
	detail.save!
	Mobility.with_locale(:id) { detail.title = "Jam Operasional"; detail.body = hours[:id]; detail.save! }
end

# The Spa page's own gallery feeds the Gallery page's Spa tab; use the design's six photos.
if spa
	spa.images.purge if spa.images.attached?
	(1..6).each { |i| spa.images.attach(io: p27_photo("root-gallery-#{i}").open, filename: "spa-gallery-#{i}.jpg") }
	spa.normalize_image_positions! if spa.respond_to?(:normalize_image_positions!)
end

# --- Facility tiles and treatment / service cards, by position ---
if recovery
	plunge = recovery.amenities.find_by("name @> ?", { en: "Plunge Pools" }.to_json)
	if plunge
		plunge.update_columns(name: { "en" => "Plunge Pool", "id" => "Kolam Plunge" })
	end
end

{ spa => "spa-fac", recovery => "rec-fac" }.each do |facility, prefix|
	next unless facility
	facility.amenities.order(:position).each_with_index do |amenity, i|
		p27_attach(amenity, :image, p27_photo("#{prefix}-#{i + 1}")) if i < 5
	end
end
{ spa => ["spa-treat", 6], recovery => ["rec-treat", 3], anti => ["aa-service", 3] }.each do |facility, (prefix, count)|
	next unless facility
	facility.treatments.order(:position).each_with_index do |treatment, i|
		p27_attach(treatment, :image, p27_photo("#{prefix}-#{i + 1}")) if i < count
	end
end

# --- Specialists (Anti-Aging) ---
TeamMember.where(department: "specialists").order(:id).each_with_index do |member, i|
	p27_attach(member, :photo, p27_photo("aa-spec-#{(i % 3) + 1}"))
end

puts "spa phase 6 applied"
