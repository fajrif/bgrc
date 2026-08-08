# The three Spa + Wellness sections (Spa, Recovery, Anti Aging) share the Club
# Life page template, with a treatment card row where the sport pages carry a
# class programme. Photography comes from vendor/assets/images/downloads.
# Idempotent: upserts by English name, attaches an image only when none is there.
puts "create spa pages"

SPA_IMAGES = Rails.root.join("vendor/assets/images")
SPA_DOWNLOADS = Rails.root.join("vendor/assets/images/downloads")
SPA_MIDDLE_BANNER = Rails.root.join("vendor/assets/images/middle-banners")

def spa_facility(en_name)
	Facility.find_by("name @> ?", { en: en_name }.to_json)
end

def spa_middle_banner!(facility, file)
	return if facility.middle_banner.attached?
	facility.middle_banner.attach(io: SPA_MIDDLE_BANNER.join(file).open, filename: file)
	puts "Middle banner: #{facility.en_name} <- #{file}"
end

def spa_detail!(facility, en_title, id_title:, en_body:, id_body:, position:)
	record = FacilityDetail.where(facility_id: facility.id).find_by("title @> ?", { en: en_title }.to_json) ||
					 FacilityDetail.new(facility: facility)

	record.facility = facility
	record.position = position
	record.title = en_title
	record.body  = en_body
	record.save!

	Mobility.with_locale(:id) do
		record.title = id_title
		record.body  = id_body
		record.save!
	end

	puts "Info block: #{facility.en_name} / #{en_title}"
	record
end

def spa_amenity!(facility, en_name, id_name:, en_desc:, id_desc:, image:, position:)
	record = Amenity.find_by("name @> ?", { en: en_name }.to_json) || Amenity.new

	record.facility = facility
	record.position = position
	record.name = en_name
	record.short_description = en_desc
	if image.present? && !record.image.attached?
		record.image.attach(io: SPA_DOWNLOADS.join(image).open, filename: image)
	end
	record.save!

	Mobility.with_locale(:id) do
		record.name = id_name
		record.short_description = id_desc
		record.save!
	end

	puts "Amenity: #{record.name} (#{facility.en_name})"
	record
end

def spa_treatment!(facility, en_name, id_name:, en_desc:, id_desc:, duration:, price:, image:, position:)
	record = Treatment.where(facility_id: facility.id).find_by("name @> ?", { en: en_name }.to_json) ||
					 Treatment.new(facility: facility)

	record.facility = facility
	record.position = position
	record.name     = en_name
	record.short_description = en_desc
	record.duration = duration
	record.price    = price
	if image.present? && !record.image.attached?
		record.image.attach(io: SPA_DOWNLOADS.join(image).open, filename: image)
	end
	record.save!

	Mobility.with_locale(:id) do
		record.name = id_name
		record.short_description = id_desc
		record.save!
	end

	puts "Treatment: #{facility.en_name} / #{en_name}"
	record
end

# These three pages carry real spa photography, so the placeholder gallery an
# earlier seed left behind is replaced outright rather than kept.
SPA_GALLERY = ["gallery-1.png", "gallery-2.png", "gallery-3.png",
							 "gallery-4.png", "gallery-5.png", "gallery-6.png"]

def spa_gallery!(facility)
	return if facility.images.attached? &&
						facility.images.map { |img| img.blob.filename.to_s }.sort == SPA_GALLERY.sort

	facility.images.purge if facility.images.attached?
	SPA_GALLERY.each do |file|
		facility.images.attach(io: SPA_DOWNLOADS.join(file).open, filename: file)
	end
	puts "Gallery: #{facility.en_name} (#{SPA_GALLERY.size} photos)"
end

def spa_page!(facility, en_intro: nil, id_intro: nil, treatments_title: nil,
							id_treatments_title: nil, specialists: false)
	facility.facilities_intro = en_intro if en_intro
	facility.treatments_title = treatments_title if treatments_title
	facility.show_specialists = specialists
	facility.save!

	Mobility.with_locale(:id) do
		facility.facilities_intro = id_intro if id_intro
		facility.treatments_title = id_treatments_title if id_treatments_title
		facility.save!
	end
end

# ---------------------------------------------------------------------------
# Spa
# ---------------------------------------------------------------------------
spa = spa_facility("Spa")
if spa
	spa_middle_banner!(spa, "middle-banner-spa.png")

	spa_page!(spa,
		en_intro: "Every room is set up for a full treatment without moving between spaces — hydrotherapy, thermal and rest areas all sit within the same wing.",
		id_intro: "Setiap ruangan disiapkan untuk perawatan lengkap tanpa perlu berpindah tempat — area hidroterapi, termal, dan istirahat berada di sayap yang sama.",
		specialists: false)

	spa_detail!(spa, "Operating Hours",
		id_title: "Jam Operasional",
		en_body: "Monday – Friday: 06:00 AM – 06:00 PM\nSaturday – Sunday: 05:30 AM – 06:30 PM\nPublic Holidays: 05:30 AM – 06:30 PM\nLast treatment starts one hour before closing, and the thermal suites close thirty minutes after that.",
		id_body: "Senin – Jumat: 06.00 – 18.00\nSabtu – Minggu: 05.30 – 18.30\nHari Libur Nasional: 05.30 – 18.30\nPerawatan terakhir dimulai satu jam sebelum tutup, dan thermal suite tutup tiga puluh menit setelahnya.",
		position: 1)

	[
		["Treatment Room", "Ruang Perawatan", "facility-3.png",
		 "Private rooms for single or couples treatments, each with its own shower.",
		 "Ruang privat untuk perawatan tunggal atau berpasangan, masing-masing dengan shower sendiri."],
		["Relaxation Lounge", "Lounge Relaksasi", "gallery-2.png",
		 "Where you wait before a treatment and settle afterwards, with tea and water on hand.",
		 "Tempat menunggu sebelum perawatan dan bersantai setelahnya, dengan teh dan air tersedia."],
		["Hydrotherapy", "Hidroterapi", "facility-1.png",
		 "Warm and cold immersion pools used on their own or between treatments.",
		 "Kolam rendam hangat dan dingin, digunakan sendiri atau di antara perawatan."],
		["Thermal Suites", "Thermal Suite", "facility-2.png",
		 "Dry sauna and steam room, open through the day to anyone with a booking.",
		 "Sauna kering dan ruang uap, terbuka sepanjang hari bagi siapa pun yang memiliki reservasi."],
		["Experience Showers", "Experience Shower", "facility-4.png",
		 "Rain, mist and cold-plunge showers to finish a thermal circuit properly.",
		 "Shower hujan, kabut, dan cold plunge untuk menutup sirkuit termal dengan sempurna."]
	].each_with_index do |(en, id, image, en_desc, id_desc), index|
		spa_amenity!(spa, en, id_name: id, en_desc: en_desc, id_desc: id_desc, image: image, position: index + 1)
	end

	[
		["Massage", "Pijat", "treatment-6.png", "60 minutes", "Rp 800.000",
		 "Balinese, deep tissue or aromatherapy, worked to the pressure you ask for.",
		 "Balinese, deep tissue, atau aromaterapi, dengan tekanan sesuai permintaan Anda."],
		["Facial", "Facial", "treatment-5.png", "60 minutes", "Rp 800.000",
		 "Cleanse, exfoliation and mask, chosen after a short skin consultation.",
		 "Pembersihan, eksfoliasi, dan masker, dipilih setelah konsultasi kulit singkat."],
		["Reflexology", "Refleksologi", "treatment-1.png", "60 minutes", "Rp 650.000",
		 "Pressure point work through the feet and lower legs, good after a long round.",
		 "Penanganan titik tekan pada kaki dan betis, cocok setelah bermain golf seharian."],
		["Body Scrub", "Lulur Tubuh", "treatment-2.png", "60 minutes", "Rp 700.000",
		 "A full-body exfoliation finished with a wrap and moisturiser.",
		 "Eksfoliasi seluruh tubuh yang ditutup dengan body wrap dan pelembap."],
		["Hair & Scalp", "Rambut & Kulit Kepala", "treatment-4.png", "45 minutes", "Rp 550.000",
		 "A conditioning treatment with a scalp massage, ideal after days in the sun.",
		 "Perawatan kondisioner dengan pijat kulit kepala, ideal setelah berhari-hari di bawah matahari."],
		["Hot Stone", "Batu Panas", "treatment-3.png", "90 minutes", "Rp 950.000",
		 "Heated basalt stones worked along the back and shoulders to release tension.",
		 "Batu basalt hangat yang digunakan di punggung dan bahu untuk melepas ketegangan."]
	].each_with_index do |(en, id, image, duration, price, en_desc, id_desc), index|
		spa_treatment!(spa, en, id_name: id, en_desc: en_desc, id_desc: id_desc,
									 duration: duration, price: price, image: image, position: index + 1)
	end

	spa_gallery!(spa)
end

# ---------------------------------------------------------------------------
# Recovery
# ---------------------------------------------------------------------------
recovery = spa_facility("Recovery")
if recovery
	spa_middle_banner!(recovery, "middle-banner-recovery.png")

	spa_page!(recovery,
		en_intro: "Built for members who train hard through the week — contrast bathing, heat and hands-on work, all in one circuit.",
		id_intro: "Dirancang untuk anggota yang berlatih keras sepanjang minggu — mandi kontras, terapi panas, dan penanganan langsung dalam satu sirkuit.",
		specialists: false)

	[
		["Plunge Pools", "Kolam Plunge", "facility-1.png",
		 "Hot and cold plunges side by side, for contrast bathing after a hard session.",
		 "Kolam plunge panas dan dingin berdampingan, untuk mandi kontras setelah latihan berat."],
		["Sports Massage", "Pijat Olahraga", "treatment-6.png",
		 "Deep tissue and trigger point work from therapists who treat athletes daily.",
		 "Deep tissue dan trigger point oleh terapis yang menangani atlet setiap hari."],
		["Sauna", "Sauna", "facility-2.png",
		 "A traditional dry sauna, kept hot from opening through to close.",
		 "Sauna kering tradisional, tetap panas dari buka hingga tutup."],
		["Steam Room", "Ruang Uap", "facility-4.png",
		 "Eucalyptus steam for the airways and for loosening off between sets.",
		 "Uap eukaliptus untuk saluran napas dan untuk melemaskan otot di antara sesi."],
		["Other Recovery Modalities", "Modalitas Pemulihan Lain", "facility-3.png",
		 "Compression boots, percussion therapy and guided stretching on request.",
		 "Compression boot, terapi perkusi, dan peregangan terpandu sesuai permintaan."]
	].each_with_index do |(en, id, image, en_desc, id_desc), index|
		spa_amenity!(recovery, en, id_name: id, en_desc: en_desc, id_desc: id_desc, image: image, position: index + 1)
	end

	[
		["Sports Recovery Massage", "Pijat Pemulihan Olahraga", "treatment-6.png", "60 minutes", "Rp 850.000",
		 "Targeted work on the muscles you have loaded hardest this week.",
		 "Penanganan terarah pada otot yang paling banyak Anda bebani minggu ini."],
		["Deep Tissue Release", "Pelepasan Deep Tissue", "treatment-1.png", "60 minutes", "Rp 900.000",
		 "Slower, firmer pressure for long-standing tightness rather than fresh soreness.",
		 "Tekanan lebih lambat dan kuat untuk kekakuan lama, bukan nyeri yang baru muncul."],
		["Lymphatic Drainage", "Drainase Limfatik", "treatment-2.png", "75 minutes", "Rp 900.000",
		 "Light rhythmic work to reduce swelling and speed up recovery between events.",
		 "Gerakan ringan dan berirama untuk mengurangi pembengkakan dan mempercepat pemulihan."]
	].each_with_index do |(en, id, image, duration, price, en_desc, id_desc), index|
		spa_treatment!(recovery, en, id_name: id, en_desc: en_desc, id_desc: id_desc,
									 duration: duration, price: price, image: image, position: index + 1)
	end

	spa_gallery!(recovery)
end

# ---------------------------------------------------------------------------
# Anti Aging — services rather than treatments, and the only Spa + Wellness
# page that fronts the specialist team.
# ---------------------------------------------------------------------------
anti_aging = spa_facility("Anti Aging")
if anti_aging
	spa_middle_banner!(anti_aging, "middle-banner-anti-aging.png")

	spa_page!(anti_aging,
		treatments_title: "Services",
		id_treatments_title: "Layanan",
		specialists: true)

	[
		["Longevity Consultation", "Konsultasi Longevity", "treatment-5.png", "", "Rp 1.500.000",
		 "A full assessment with one of our specialists, and the plan that comes out of it.",
		 "Asesmen menyeluruh bersama salah satu spesialis kami, beserta rencana yang dihasilkannya."],
		["Skin Renewal Programme", "Program Peremajaan Kulit", "gallery-3.png", "", "Rp 6.500.000",
		 "A course of facials and topical therapy planned over three months, not one visit.",
		 "Rangkaian facial dan terapi topikal yang direncanakan selama tiga bulan, bukan sekali kunjungan."],
		["Regenerative Therapy", "Terapi Regeneratif", "gallery-6.png", "", "Rp 9.500.000",
		 "Recovery, nutrition and treatment combined into one supervised programme.",
		 "Pemulihan, nutrisi, dan perawatan digabung dalam satu program dengan pengawasan."]
	].each_with_index do |(en, id, image, duration, price, en_desc, id_desc), index|
		spa_treatment!(anti_aging, en, id_name: id, en_desc: en_desc, id_desc: id_desc,
									 duration: duration, price: price, image: image, position: index + 1)
	end

	spa_gallery!(anti_aging)
end
