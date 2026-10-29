# Phase 5 Fitness pages — the Fitness root plus Gym, Gyrotonic, Pilates, Yoga and
# Lap Pool. Photography (cropped from the design) ships in
# vendor/assets/images/new-design/fitness. Idempotent: records are upserted by
# English name and the design's photos replace whatever is attached.
# Run after 22_create_fitness_pages.rb — that file hides the pricing row, this one
# publishes it again for the four pages that have real membership rates.
puts "create phase 5 fitness content"

P5_IMAGES = Rails.root.join("vendor/assets/images/new-design/fitness")

def p5_facility(en_name)
	Facility.find_by("name @> ?", { en: en_name }.to_json)
end

def p5_file(path)
	P5_IMAGES.join(path).open
end

# purge whatever is attached and attach the design's photo
def p5_replace!(attachment, path)
	attachment.purge if attachment.attached?
	attachment.attach(io: p5_file(path), filename: File.basename(path))
end

def p5_gallery!(facility, dir)
	facility.images.purge if facility.images.attached?
	(1..6).each { |n| facility.images.attach(io: p5_file("#{dir}/gallery-#{n}.jpg"), filename: "#{dir}-gallery-#{n}.jpg") }
	puts "Gallery: #{facility.en_name} (6 photos)"
end

def p5_translate!(record, id_attrs)
	Mobility.with_locale(:id) do
		id_attrs.each { |attr, value| record.public_send("#{attr}=", value) }
		record.save!
	end
end

def p5_detail!(facility, en_title, id_title:, en_body:, id_body:, position:)
	record = FacilityDetail.where(facility_id: facility.id).find_by("title @> ?", { en: en_title }.to_json) ||
					 FacilityDetail.new(facility: facility)
	record.assign_attributes(position: position, title: en_title, body: en_body)
	record.save!
	p5_translate!(record, title: id_title, body: id_body)
end

def p5_rate!(facility, en_name, id_name:, time:, en_access:, id_access:, price:, position:, image:)
	record = FacilityRate.where(facility_id: facility.id).find_by("name @> ?", { en: en_name }.to_json) ||
					 FacilityRate.new(facility: facility)
	record.assign_attributes(position: position, name: en_name, time: time, access: en_access, price: price)
	record.save!
	p5_replace!(record.image, image)
	p5_translate!(record, name: id_name, access: id_access)
end

def p5_treatment!(facility, en_name, id_name:, category:, duration:, price:, position:, image:)
	private_class = category == "private_lesson"
	en_desc = private_class ? "One-to-one coaching built around your goals, adjusted session by session as you progress." :
														"A small-group session where the coach keeps form and pace on track for everyone."
	id_desc = private_class ? "Pelatihan satu lawan satu yang disesuaikan dengan tujuan Anda dan diatur setiap sesi seiring kemajuan Anda." :
														"Sesi kelompok kecil dengan pelatih yang menjaga bentuk gerakan dan ritme tiap peserta."
	record = Treatment.where(facility_id: facility.id).find_by("name @> ?", { en: en_name }.to_json) ||
					 Treatment.new(facility: facility)
	record.assign_attributes(position: position, name: en_name, short_description: en_desc, duration: duration,
													 price: price, category: category)
	record.save!
	p5_replace!(record.image, image)
	p5_translate!(record, name: id_name, short_description: id_desc)
end

def p5_benefit!(facility, en_title, id_title:, en_desc:, id_desc:, icon:, position:)
	record = FacilityBenefit.where(facility_id: facility.id).find_by("title @> ?", { en: en_title }.to_json) ||
					 FacilityBenefit.new(facility: facility)
	record.assign_attributes(position: position, title: en_title, description: en_desc)
	record.save!
	p5_replace!(record.icon, "icons/#{icon}.png")
	p5_translate!(record, title: id_title, description: id_desc)
end

def p5_amenity_photos!(facility, dir)
	facility.amenities.each_with_index do |amenity, index|
		p5_replace!(amenity.image, "#{dir}/facility-#{index + 1}.jpg")
	end
end

# the shared class-description helpers read "Private Lesson" / "Group Class"
PRIVATE = "private_lesson".freeze
GROUP   = "group_class".freeze

# --- Fitness root -----------------------------------------------------------
if (fitness = p5_facility("Fitness"))
	fitness.update!(cta_label: "Visit BBCC Fitness", cta_url: "/club-life/fitness/gym",
									facilities_intro: "From free weights and reformers to the pool, everything you need to train, recover and unwind sits within a few steps of each other.")
	Mobility.with_locale(:id) do
		fitness.update!(cta_label: "Kunjungi BBCC Fitness",
										facilities_intro: "Dari beban bebas dan reformer hingga kolam renang, semua yang Anda butuhkan untuk berlatih, memulihkan diri, dan bersantai berada dalam jarak beberapa langkah.")
	end
	p5_replace!(fitness.banner, "banners/banner-fitness.jpg")
	p5_replace!(fitness.middle_banner, "banners/banner-sauna.jpg")
	p5_gallery!(fitness, "root")

	# the Fitness team: placeholders from the design, replaced with real people in admin
	3.times do |index|
		member = TeamMember.where(department: "fitness", position: index + 1).first ||
						 TeamMember.new(department: "fitness", position: index + 1)
		member.assign_attributes(name: "John Doe", role: "Role / Title",
														 bio: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore.")
		member.save!
		p5_replace!(member.photo, "team/team-#{index + 1}.jpg")
		p5_translate!(member, role: "Peran / Jabatan", bio: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore.")
	end
end

# --- the four class pages ---------------------------------------------------
PAGES = {
	"Gym" => {
		dir: "gym", banner: "banner-gym.jpg", card: "root/card-1.jpg", id_classes: "Kelas Gym",
		classes: [
			["Strength Foundations", "Dasar-dasar Kekuatan", PRIVATE, "60 minutes", "Rp 350.000"],
			["Personal Training", "Personal Training", PRIVATE, "60 minutes", "Rp 400.000"],
			["Barbell Basics", "Dasar Barbell", GROUP, "60 minutes", "Rp 200.000"],
			["Dumbbell Circuit", "Sirkuit Dumbbell", GROUP, "45 minutes", "Rp 180.000"],
			["Olympic Lifting Intro", "Pengantar Angkat Beban Olimpik", PRIVATE, "60 minutes", "Rp 450.000"],
			["Functional Conditioning", "Kondisi Fungsional", GROUP, "45 minutes", "Rp 200.000"]
		]
	},
	"Gyrotonic" => {
		dir: "gyrotonic", banner: "banner-gyrotonic.jpg", card: "root/card-2.jpg", id_classes: "Kelas Gyrotonic",
		classes: [
			["Gyrotonic Private", "Gyrotonic Privat", PRIVATE, "55 minutes", "Rp 550.000"],
			["Gyrotonic Duet", "Gyrotonic Duet", PRIVATE, "55 minutes", "Rp 350.000"],
			["Spine & Mobility", "Tulang Belakang & Mobilitas", GROUP, "55 minutes", "Rp 250.000"],
			["Strength Flow", "Strength Flow", GROUP, "55 minutes", "Rp 250.000"],
			["Rehab & Recovery", "Rehabilitasi & Pemulihan", PRIVATE, "55 minutes", "Rp 600.000"],
			["Intro Group Class", "Kelas Grup Pengantar", GROUP, "55 minutes", "Rp 200.000"]
		]
	},
	"Pilates" => {
		dir: "pilates", banner: "banner-pilates.jpg", card: "root/card-3.jpg", id_classes: "Kelas Pilates",
		classes: [
			["Reformer Foundations", "Dasar Reformer", PRIVATE, "55 minutes", "Rp 600.000"],
			["Reformer Flow", "Reformer Flow", PRIVATE, "55 minutes", "Rp 600.000"],
			["Reformer Group", "Reformer Grup", GROUP, "55 minutes", "Rp 250.000"],
			["Mat Pilates", "Pilates Matras", GROUP, "50 minutes", "Rp 180.000"],
			["Pre & Postnatal Reformer", "Reformer Pra & Pascanatal", PRIVATE, "55 minutes", "Rp 650.000"],
			["Pilates Sculpt", "Pilates Sculpt", GROUP, "50 minutes", "Rp 220.000"]
		]
	},
	"Yoga" => {
		dir: "yoga", banner: "banner-yoga.jpg", card: "yoga/pricing-3.jpg", id_classes: "Kelas Yoga",
		classes: [
			["Private Vinyasa", "Vinyasa Privat", PRIVATE, "60 minutes", "Rp 500.000"],
			["Sunset Flow", "Flow Matahari Terbenam", PRIVATE, "60 minutes", "Rp 450.000"],
			["Hatha Group", "Hatha Grup", GROUP, "60 minutes", "Rp 180.000"],
			["Sunrise Yoga", "Yoga Matahari Terbit", GROUP, "60 minutes", "Rp 180.000"],
			["Restorative & Yin", "Restoratif & Yin", PRIVATE, "75 minutes", "Rp 450.000"],
			["Power Yoga", "Power Yoga", GROUP, "60 minutes", "Rp 200.000"]
		]
	}
}.freeze

PAGES.each do |name, page|
	facility = p5_facility(name)
	next puts("Skipped #{name}: no facility") if facility.nil?

	facility.update!(show_pricing: true, show_coaches: true, cta_url: "", treatments_title: "#{name} Classes")
	Mobility.with_locale(:id) { facility.update!(treatments_title: page[:id_classes]) }
	p5_replace!(facility.banner, "banners/#{page[:banner]}")
	p5_replace!(facility.image, page[:card])
	facility.middle_banner.purge if facility.middle_banner.attached?
	p5_gallery!(facility, page[:dir])
	p5_amenity_photos!(facility, page[:dir])

	facility.facility_rates.each_with_index do |rate, index|
		p5_replace!(rate.image, "#{page[:dir]}/pricing-#{[index + 1, 4].min}.jpg")
	end

	page[:classes].each_with_index do |(en, id, category, duration, price), index|
		p5_treatment!(facility, en, id_name: id, category: category, duration: duration, price: price,
									position: index + 1, image: "#{page[:dir]}/class-#{index + 1}.jpg")
	end
	puts "Page: #{name}"
end

# --- Pilates: the design prices reformer and mat sessions ---------------------
if (pilates = p5_facility("Pilates"))
	keep = ["Reformer (Private)", "Reformer (Group)", "Mat (Private)", "Mat (Group)"]
	[
		["Reformer (Private)", "Reformer (Privat)", "One-to-one, 55 minutes", "Satu lawan satu, 55 menit", "Rp 600.000"],
		["Reformer (Group)", "Reformer (Grup)", "Small group, up to 8", "Grup kecil, maksimal 8", "Rp 250.000"],
		["Mat (Private)", "Matras (Privat)", "One-to-one, 50 minutes", "Satu lawan satu, 50 menit", "Rp 450.000"],
		["Mat (Group)", "Matras (Grup)", "Group class, up to 14", "Kelas grup, maksimal 14", "Rp 180.000"]
	].each_with_index do |(en, id, en_access, id_access, price), index|
		p5_rate!(pilates, en, id_name: id, time: "06:30 AM – 07:30 PM", en_access: en_access, id_access: id_access,
						 price: price, position: index + 1, image: "pilates/pricing-#{index + 1}.jpg")
	end
	pilates.facility_rates.reject { |rate| keep.include?(rate.name) }.each(&:destroy)
end

# --- Benefit rows (Gyrotonic and Pilates) ---------------------------------------
if (gyrotonic = p5_facility("Gyrotonic"))
	[
		["Spinal Mobility", "Mobilitas Tulang Belakang", "tabler_stretching", "Fluid, circular movement that opens the spine and hips.", "Gerakan melingkar yang luwes untuk membuka tulang belakang dan pinggul."],
		["Core Strength", "Kekuatan Inti", "game-icons_strong", "Build deep stabilising strength without heavy loading.", "Bangun kekuatan penstabil yang dalam tanpa beban berat."],
		["Joint Health", "Kesehatan Sendi", "hugeicons_equipment-gym-02", "Low-impact work that keeps joints moving through full range.", "Latihan berdampak rendah yang menjaga sendi bergerak penuh."],
		["Coordination", "Koordinasi", "hugeicons_equipment-gym-03", "Pulley and tower work that trains balance and timing.", "Latihan pulley dan tower yang melatih keseimbangan dan ritme."]
	].each_with_index do |(en, id, icon, en_desc, id_desc), index|
		p5_benefit!(gyrotonic, en, id_title: id, en_desc: en_desc, id_desc: id_desc, icon: icon, position: index + 1)
	end
end

if pilates
	[
		["Core Strength", "Kekuatan Inti", "game-icons_strong", "Control built from the centre out, one precise movement at a time.", "Kontrol yang dibangun dari pusat tubuh, satu gerakan presisi demi satu."],
		["Posture & Alignment", "Postur & Keselarasan", "hugeicons_equipment-gym-02", "Longer, stronger posture for desk days and active days alike.", "Postur yang lebih panjang dan kuat untuk hari kerja maupun hari aktif."],
		["Balance & Control", "Keseimbangan & Kontrol", "hugeicons_equipment-gym-03", "Spring-based resistance that rewards slow, deliberate work.", "Resistensi pegas yang menghargai gerakan pelan dan terukur."],
		["Flexibility", "Fleksibilitas", "tabler_stretching", "Lengthen tight hips, hamstrings and shoulders safely.", "Panjangkan pinggul, hamstring, dan bahu yang kaku dengan aman."]
	].each_with_index do |(en, id, icon, en_desc, id_desc), index|
		p5_benefit!(pilates, en, id_title: id, en_desc: en_desc, id_desc: id_desc, icon: icon, position: index + 1)
	end
end

# --- Lap Pool: intro, info blocks and a gallery only ----------------------------
if (pool = p5_facility("Lap Pool"))
	pool.update!(show_pricing: false, show_coaches: false, cta_url: "")
	p5_replace!(pool.banner, "banners/banner-lap-pool.jpg")
	p5_replace!(pool.image, "lap-pool/gallery-2.jpg")
	pool.middle_banner.purge if pool.middle_banner.attached?
	p5_gallery!(pool, "lap-pool")
	pool.facility_rates.destroy_all
	pool.amenities.destroy_all

	p5_detail!(pool, "Maximum Lane Capacity", id_title: "Kapasitas Maksimal Lintasan", position: 3,
		en_body: "Maximum of 4 swimmers per lane at any given time to avoid crowding.",
		id_body: "Maksimal 4 perenang per lintasan pada satu waktu agar kolam tidak terlalu padat.")
	p5_detail!(pool, "Rules & Guidelines", id_title: "Aturan & Panduan", position: 4,
		en_body: "- Shower First: All swimmers must take a cleansing shower before entering the pool deck to maintain water quality.\n- Proper Swim Attire: Only proper swimwear (nylon/spandex) is permitted. Cotton clothing, gym shorts, and undergarments are strictly prohibited.\n- No Food or Glass: Food, chewing gum, and glass containers are strictly banned from the pool deck. Only water in plastic, shatterproof bottles is allowed.",
		id_body: "- Mandi Terlebih Dahulu: Semua perenang wajib mandi bersih sebelum memasuki area kolam untuk menjaga kualitas air.\n- Pakaian Renang yang Sesuai: Hanya pakaian renang yang layak (nilon/spandeks) yang diperbolehkan. Pakaian katun, celana gym, dan pakaian dalam dilarang.\n- Tanpa Makanan atau Kaca: Makanan, permen karet, dan wadah kaca dilarang di area kolam. Hanya air dalam botol plastik antipecah yang diperbolehkan.")
end

puts "phase 5 fitness content ready"
