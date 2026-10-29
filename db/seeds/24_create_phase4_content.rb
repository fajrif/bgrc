# Phase 4 Club Life pages — Golf Course, Golf Lessons & Academy, Driving Range,
# Beach Club and the Racquet Sports banners. Photography ships in
# vendor/assets/images/new-design/club-life. Idempotent: details, rates,
# treatments and amenities are upserted by English name; a banner is only
# replaced when `replace:` says so (the supplied Phase 4 banners are meant to win).
puts "create phase 4 club life content"

P4_IMAGES = Rails.root.join("vendor/assets/images/new-design/club-life")

def p4_facility(en_name)
	Facility.find_by("name @> ?", { en: en_name }.to_json)
end

def p4_file(path)
	P4_IMAGES.join(path).open
end

def p4_banner!(facility, path, replace: true)
	return if facility.nil? || (facility.banner.attached? && !replace)
	facility.banner.purge if facility.banner.attached?
	facility.banner.attach(io: p4_file(path), filename: File.basename(path))
	puts "Banner: #{facility.en_name} <- #{path}"
end

def p4_translate!(record, id_attrs)
	Mobility.with_locale(:id) do
		id_attrs.each { |attr, value| record.public_send("#{attr}=", value) }
		record.save!
	end
end

def p4_detail!(facility, en_title, id_title:, en_body:, id_body:, position:)
	record = FacilityDetail.where(facility_id: facility.id).find_by("title @> ?", { en: en_title }.to_json) ||
					 FacilityDetail.new(facility: facility)
	record.assign_attributes(position: position, title: en_title, body: en_body)
	record.save!
	p4_translate!(record, title: id_title, body: id_body)
end

def p4_amenity!(facility, en_name, id_name:, en_desc:, id_desc:, position:, image: nil)
	record = Amenity.where(facility_id: facility.id).find_by("name @> ?", { en: en_name }.to_json) ||
					 Amenity.new(facility: facility)
	record.assign_attributes(position: position, name: en_name, short_description: en_desc)
	record.image.attach(io: p4_file(image), filename: File.basename(image)) if image && !record.image.attached?
	record.save!
	p4_translate!(record, name: id_name, short_description: id_desc)
end

def p4_treatment!(facility, en_name, id_name:, en_desc:, id_desc:, duration:, price:, position:, image: nil)
	record = Treatment.where(facility_id: facility.id).find_by("name @> ?", { en: en_name }.to_json) ||
					 Treatment.new(facility: facility)
	record.assign_attributes(position: position, name: en_name, short_description: en_desc, duration: duration, price: price)
	record.image.attach(io: p4_file(image), filename: File.basename(image)) if image && !record.image.attached?
	record.save!
	p4_translate!(record, name: id_name, short_description: id_desc)
end

def p4_rate!(facility, en_name, id_name:, time:, en_access:, id_access:, price:, position:)
	record = FacilityRate.where(facility_id: facility.id).find_by("name @> ?", { en: en_name }.to_json) ||
					 FacilityRate.new(facility: facility)
	record.assign_attributes(position: position, name: en_name, time: time, access: en_access, price: price)
	record.save!
	p4_translate!(record, name: id_name, access: id_access)
end

# --- banners the design supplies ---
{ "Golf Course" => "golf/banner-golf-course.jpg", "Beach Club" => "beach-club/banner-beach-club.jpg",
	"Racquet Sports" => "racquet/banner-racquet.jpg", "Tennis" => "racquet/banner-tennis.jpg",
	"Padel" => "racquet/banner-padel.jpg", "Pickleball" => "racquet/banner-pickleball.jpg" }.each do |name, path|
	p4_banner!(p4_facility(name), path)
end

# --- Golf Course ---
if (course = p4_facility("Golf Course"))
	course.update!(cta_label: "Book Golf Course Now", cta_url: "/book/golf", facilities_intro:
		"From the practice range to the clubhouse, everything you need for a day on the course is within easy reach.")
	p4_detail!(course, "Course Specifications", id_title: "Spesifikasi Lapangan", position: 1,
		en_body: "Available Holes: 9 / 18 Holes\nPar: 36 for 9 holes / 72 for 18 holes\nCourse Length: Approx. 3,100 meters for 9 holes / 6,200 meters for 18 holes\nSurface: Natural grass fairway with maintained putting greens\nTee Time Interval: Every 10 minutes\nMax Players per Group: 4 players\nCourse Type: Resort-style golf course\nDifficulty Level: Beginner to intermediate friendly\nFacilities: Locker room, cart service, driving range, clubhouse, and equipment rental",
		id_body: "Jumlah Hole: 9 / 18 Hole\nPar: 36 untuk 9 hole / 72 untuk 18 hole\nPanjang Lapangan: Sekitar 3.100 meter untuk 9 hole / 6.200 meter untuk 18 hole\nPermukaan: Fairway rumput alami dengan green yang terawat\nInterval Tee Time: Setiap 10 menit\nMaksimal Pemain per Grup: 4 pemain\nJenis Lapangan: Lapangan golf bergaya resor\nTingkat Kesulitan: Ramah untuk pemula hingga menengah\nFasilitas: Ruang loker, layanan cart, driving range, clubhouse, dan penyewaan peralatan")
	p4_detail!(course, "Operating Hours", id_title: "Jam Operasional", position: 2,
		en_body: "Monday - Friday: 06.00 AM - 06.00 PM\nSaturday - Sunday: 05.30 AM - 06.30 PM\nPublic Holidays: 05.30 AM - 06.30 PM\n\nLast tee time may vary depending on weather conditions, course availability, and daylight hours.",
		id_body: "Senin - Jumat: 06.00 - 18.00\nSabtu - Minggu: 05.30 - 18.30\nHari Libur Nasional: 05.30 - 18.30\n\nTee time terakhir dapat berbeda tergantung cuaca, ketersediaan lapangan, dan cahaya matahari.")
	[
		["Driving Range", "Driving Range", "golf/img-golf-course-1.jpg", "Warm up on grass tees with a full set of target greens."],
		["Golf Cart Rental", "Sewa Golf Cart", "golf/img-golf-course-5.jpg", "Electric carts with a caddy bag rack, available for every round."],
		["Locker Room", "Ruang Loker", "golf/img-golf-course-3.jpg", "Private lockers and changing rooms for members and guests."],
		["Equipment Rental", "Sewa Peralatan", "golf/img-golf-course-2.jpg", "Quality club sets and accessories available on request."],
		["Clubhouse", "Clubhouse", "golf/img-golf-course-4.jpg", "Relax after your round with views over the course."]
	].each_with_index do |(en, id, image, desc), index|
		p4_amenity!(course, en, id_name: id, en_desc: desc, id_desc: desc, image: image, position: index + 1)
	end
end

# --- Golf Lessons & Academy ---
if (lessons = p4_facility("Golf Lessons & Academy"))
	lessons.update!(show_coaches: true, show_pricing: false, cta_label: "Book Now", cta_url: "/book/golf")
	lessons.update!(treatments_title: "BBCC Golf Classes")
	Mobility.with_locale(:id) { lessons.update!(treatments_title: "Kelas Golf BBCC") }
	[
		["Beginner Golf Class", "Kelas Golf Pemula", "Duration 60 minutes\nPax 1-4 players", "Rp. 350.000 / session", "golf/img-golf-course-1.jpg"],
		["Junior Golf Class", "Kelas Golf Junior", "Duration 45 minutes\nPax 1-3 players", "Rp. 250.000 / session", "golf/img-golf-course-2.jpg"],
		["Private Coaching", "Pelatihan Privat", "Duration 90 minutes\nPax 1 player", "Rp. 600.000 / session", "golf/img-golf-course-4.jpg"],
		["Group Golf Clinic", "Klinik Golf Grup", "Duration 120 minutes\nPax 4-8 players", "Rp. 1.200.000 / session", "golf/img-golf-course-5.jpg"]
	].each_with_index do |(en, id, desc, price, image), index|
		p4_treatment!(lessons, en, id_name: id, en_desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.",
			id_desc: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", duration: desc.tr("\n", " · "), price: price, position: index + 1, image: image)
	end
end

# --- Driving Range ---
if (range = p4_facility("Driving Range"))
	range.update!(show_pricing: true, cta_label: "Book Driving Range Now", cta_url: "/book/golf")
	p4_detail!(range, "Facility Information", id_title: "Informasi Fasilitas", position: 1,
		en_body: "Number of Bays: 20 practice bays\nOperating Hours: Monday - Friday, 06.00 AM - 09.00 PM\nWeekend & Public Holidays: 05.30 AM - 09.00 PM\nSuitable For: Beginners, casual players, golf lessons, warm-up sessions, and private coaching\nAvailable Services: Golf ball rental, club rental, coaching sessions, and practice packages",
		id_body: "Jumlah Bay: 20 bay latihan\nJam Operasional: Senin - Jumat, 06.00 - 21.00\nAkhir Pekan & Hari Libur: 05.30 - 21.00\nCocok Untuk: Pemula, pemain santai, kelas golf, pemanasan, dan pelatihan privat\nLayanan: Sewa bola golf, sewa stik, sesi pelatihan, dan paket latihan")
	[
		["Single Bucket", "Satu Keranjang", "Duration: 60 minutes", "Pax: 1-4 players", "Rp. 350.000 / session"],
		["Double Bucket", "Dua Keranjang", "Duration: 90 minutes", "Includes: 100 golf balls", "Rp. 130.000"],
		["Practice Package", "Paket Latihan", "Duration: 120 minutes", "Includes: 150 golf balls", "Rp. 200.000"],
		["Monthly Range Pass", "Pass Bulanan", "Duration: 10 sessions, 60 minutes each", "Includes: 10 driving range sessions", "Rp. 650.000"]
	].each_with_index do |(en, id, time, access, price), index|
		p4_rate!(range, en, id_name: id, time: time.sub("Duration: ", ""), en_access: access.sub(/^(Pax|Includes): /, ""), id_access: access.sub(/^(Pax|Includes): /, ""),
			price: price, position: index + 1)
	end
end

# --- Beach Club ---
if (beach = p4_facility("Beach Club"))
	beach.update!(cta_label: "Visit BBCC Beach Club", cta_url: "/dining", facilities_intro: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.")
	[
		["Beachfront Dining", "Makan di Tepi Pantai", "Fresh seafood and cocktails with the shoreline at your feet."],
		["Sunset Bar", "Bar Sunset", "Signature drinks timed to the evening light."],
		["Poolside Lounge", "Lounge Tepi Kolam", "Light bites and long afternoons by the water."],
		["Beach Cabanas", "Kabana Pantai", "Private shade and service for a full day on the sand."]
	].each_with_index do |(en, id, desc), index|
		p4_amenity!(beach, en, id_name: id, en_desc: desc, id_desc: desc, position: index + 1)
	end
	# the design's beach photography replaces the placeholder gallery
	if beach.images.attached? && beach.images.count != 6
		beach.images.purge
	end
	unless beach.images.attached?
		%w[1 2 3 4 6 7].each { |n| beach.images.attach(io: p4_file("beach-club/img-beach-#{n}.jpg"), filename: "img-beach-#{n}.jpg") }
		beach.normalize_image_positions!
	end
end
puts "phase 4 club life content done"
