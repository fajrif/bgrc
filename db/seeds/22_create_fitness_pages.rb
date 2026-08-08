# The five Fitness sections (Gym, Gyrotonic, Pilates, Yoga, Lap Pool) share one
# page template: intro copy + info blocks, a middle banner, membership pricing,
# a facilities mosaic and a gallery. None of them is tied to a bookable sport,
# so everything below the intro comes from records hung off the Facility itself.
# Idempotent: upserts by English name, attaches an image only when none is there.
puts "create fitness pages"

FITNESS_IMAGES        = Rails.root.join("vendor/assets/images")
FITNESS_MIDDLE_BANNER = Rails.root.join("vendor/assets/images/middle-banners")

def fitness_facility(en_name)
	Facility.find_by("name @> ?", { en: en_name }.to_json)
end

def fitness_middle_banner!(facility, file)
	return if facility.middle_banner.attached?
	facility.middle_banner.attach(io: FITNESS_MIDDLE_BANNER.join(file).open, filename: file)
	puts "Middle banner: #{facility.en_name} <- #{file}"
end

def fitness_detail!(facility, en_title, id_title:, en_body:, id_body:, position:)
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

def fitness_rate!(facility, en_name, id_name:, time:, en_access:, id_access:, price:, position:)
	record = FacilityRate.where(facility_id: facility.id).find_by("name @> ?", { en: en_name }.to_json) ||
					 FacilityRate.new(facility: facility)

	record.facility = facility
	record.position = position
	record.name     = en_name
	record.time     = time
	record.access   = en_access
	record.price    = price
	record.save!

	Mobility.with_locale(:id) do
		record.name   = id_name
		record.access = id_access
		record.save!
	end

	puts "Rate: #{facility.en_name} / #{en_name}"
	record
end

def fitness_amenity!(facility, en_name, id_name:, en_desc:, id_desc:, image:, position:)
	record = Amenity.find_by("name @> ?", { en: en_name }.to_json) || Amenity.new

	record.facility = facility
	record.position = position
	record.name = en_name
	record.short_description = en_desc
	if image.present? && !record.image.attached?
		record.image.attach(io: FITNESS_IMAGES.join(image).open, filename: File.basename(image))
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

def fitness_gallery!(facility, files)
	return if facility.images.attached?
	files.each do |path|
		facility.images.attach(io: FITNESS_IMAGES.join(path).open, filename: File.basename(path))
	end
	puts "Gallery: #{facility.en_name} (#{files.size} photos)"
end

def fitness_intro!(facility, en_intro, id_intro)
	facility.facilities_intro = en_intro
	facility.save!
	Mobility.with_locale(:id) do
		facility.facilities_intro = id_intro
		facility.save!
	end
end

# The membership rates below are placeholders until the club signs them off, so
# the pricing row stays hidden on these five pages. Tick "Show pricing section"
# on the facility in the admin panel to publish it — note that re-running this
# seed hides it again, so drop this call once the prices are real.
def fitness_hide_pricing!(facility)
	facility.update!(show_pricing: false)
end

# ---------------------------------------------------------------------------
# Gym
# ---------------------------------------------------------------------------
gym = fitness_facility("Gym")
if gym
	fitness_hide_pricing!(gym)
	fitness_middle_banner!(gym, "middle-banner-gym.png")

	fitness_intro!(gym,
		"Everything on the floor is commercial-grade and laid out so each discipline has room of its own — lift, condition or train for a sport without queueing for a station.",
		"Semua peralatan di lantai gym berkualitas komersial dan ditata agar setiap disiplin punya ruangnya sendiri — angkat beban, kondisikan tubuh, atau berlatih untuk olahraga tanpa antre.")

	fitness_detail!(gym, "Operating Hours",
		id_title: "Jam Operasional",
		en_body: "Monday – Friday: 06:00 AM – 06:00 PM\nSaturday – Sunday: 05:30 AM – 06:30 PM\nPublic Holidays: 05:30 AM – 06:30 PM\nPeak Hour Note:\nOur busiest times are daily from 05:30 PM to 07:30 PM. For an ultra-smooth, spacious workout, we highly recommend planning your session during our mid-day window (11:00 AM – 03:00 PM).",
		id_body: "Senin – Jumat: 06.00 – 18.00\nSabtu – Minggu: 05.30 – 18.30\nHari Libur Nasional: 05.30 – 18.30\nCatatan Jam Sibuk:\nWaktu tersibuk kami setiap hari adalah pukul 17.30 hingga 19.30. Untuk latihan yang lebih leluasa, kami sangat menyarankan Anda datang pada jendela tengah hari (11.00 – 15.00).",
		position: 1)

	fitness_detail!(gym, "Capacity",
		id_title: "Kapasitas",
		en_body: "Max 120 members",
		id_body: "Maksimal 120 anggota",
		position: 2)

	[
		["Single Session", "Sesi Tunggal", "06:00 AM – 06:00 PM", "Single-day full access", "Akses penuh satu hari", "Rp 150.000"],
		["10-Session Pass", "Paket 10 Sesi", "06:00 AM – 06:00 PM", "Valid for 3 months", "Berlaku 3 bulan", "Rp 1.200.000"],
		["Monthly Membership", "Keanggotaan Bulanan", "06:00 AM – 06:00 PM", "Unlimited daily access", "Akses harian tanpa batas", "Rp 650.000"],
		["Yearly Membership", "Keanggotaan Tahunan", "06:00 AM – 06:00 PM", "Unlimited daily access", "Akses harian tanpa batas", "Rp 5.850.000"]
	].each_with_index do |(en, id, time, en_access, id_access, price), index|
		fitness_rate!(gym, en, id_name: id, time: time, en_access: en_access, id_access: id_access, price: price, position: index + 1)
	end

	[
		["Free Weights Floor", "Area Beban Bebas", "facilities/gym.png",
		 "Racks, benches and a full dumbbell run to 50kg, with platforms for olympic lifting.",
		 "Rak, bangku, dan dumbbell lengkap hingga 50kg, dengan platform untuk angkat beban olimpik."],
		["Cardio Deck", "Dek Kardio", "fitness.png",
		 "Treadmills, bikes, rowers and stair climbers lined along the window wall.",
		 "Treadmill, sepeda statis, rowing machine, dan stair climber berjajar di sepanjang dinding kaca."],
		["Resistance Machines", "Mesin Resistensi", "new-banners/banner-gym.png",
		 "A full pin-loaded circuit covering every major muscle group, easy to learn on.",
		 "Sirkuit pin-loaded lengkap yang mencakup seluruh kelompok otot utama dan mudah dipelajari."],
		["Functional Training Zone", "Zona Latihan Fungsional", "new-banners/banner-fitness.png",
		 "Turf, sleds, kettlebells and rigs for conditioning work and small-group sessions.",
		 "Rumput sintetis, sled, kettlebell, dan rig untuk latihan kondisi dan sesi kelompok kecil."],
		["Member Locker Rooms", "Ruang Loker Anggota", "facilities/lockers.png",
		 "Day lockers, rain showers and towel service, steps from the gym floor.",
		 "Loker harian, shower, dan layanan handuk, hanya beberapa langkah dari lantai gym."]
	].each_with_index do |(en, id, image, en_desc, id_desc), index|
		fitness_amenity!(gym, en, id_name: id, en_desc: en_desc, id_desc: id_desc, image: image, position: index + 1)
	end

	fitness_gallery!(gym, ["facilities/gym.png", "fitness.png", "new-banners/banner-gym.png",
												 "new-banners/banner-fitness.png", "facilities/lockers.png",
												 "facilities/recovery-center.png"])
end

# ---------------------------------------------------------------------------
# Gyrotonic
# ---------------------------------------------------------------------------
gyrotonic = fitness_facility("Gyrotonic")
if gyrotonic
	fitness_hide_pricing!(gyrotonic)
	fitness_middle_banner!(gyrotonic, "middle-banner-gyrotonic.png")

	fitness_intro!(gyrotonic,
		"The studio is equipped for the full Gyrotonic repertoire, so a session can move from spinal work to strength and back without changing rooms.",
		"Studio ini dilengkapi untuk seluruh repertoar Gyrotonic, sehingga satu sesi dapat berpindah dari latihan tulang belakang ke kekuatan dan kembali lagi tanpa berpindah ruangan.")

	fitness_detail!(gyrotonic, "Session Format",
		id_title: "Format Sesi",
		en_body: "Private: 55 minutes, one-to-one with a certified trainer\nDuet: 55 minutes, two clients per trainer\nGroup: 55 minutes, maximum 4 clients\n\nFirst-timers start with a private assessment so the trainer can set the tower and pulley weights to your range.",
		id_body: "Privat: 55 menit, satu lawan satu dengan pelatih bersertifikat\nDuet: 55 menit, dua klien per pelatih\nKelompok: 55 menit, maksimal 4 klien\n\nPemula memulai dengan asesmen privat agar pelatih dapat menyesuaikan tower dan beban pulley dengan jangkauan Anda.",
		position: 1)

	fitness_detail!(gyrotonic, "Capacity",
		id_title: "Kapasitas",
		en_body: "Max 4 clients per session",
		id_body: "Maksimal 4 klien per sesi",
		position: 2)

	[
		["Private Session", "Sesi Privat", "07:00 AM – 07:00 PM", "One-to-one, 55 minutes", "Satu lawan satu, 55 menit", "Rp 550.000"],
		["5-Session Pack", "Paket 5 Sesi", "07:00 AM – 07:00 PM", "Valid for 2 months", "Berlaku 2 bulan", "Rp 2.500.000"],
		["10-Session Pack", "Paket 10 Sesi", "07:00 AM – 07:00 PM", "Valid for 4 months", "Berlaku 4 bulan", "Rp 4.750.000"],
		["Monthly Unlimited", "Bulanan Tanpa Batas", "07:00 AM – 07:00 PM", "Group sessions, unlimited", "Sesi kelompok, tanpa batas", "Rp 3.200.000"]
	].each_with_index do |(en, id, time, en_access, id_access, price), index|
		fitness_rate!(gyrotonic, en, id_name: id, time: time, en_access: en_access, id_access: id_access, price: price, position: index + 1)
	end

	[
		["Pulley Tower Studio", "Studio Pulley Tower", "new-banners/banner-gyrotonic.png",
		 "Four tower combination units, the backbone of every private and duet session.",
		 "Empat unit tower combination, tulang punggung setiap sesi privat dan duet."],
		["Jumping Stretching Board", "Papan Jumping Stretching", "facilities/pilates.png",
		 "Low-impact plyometric work on a sliding board, easy on knees and hips.",
		 "Latihan plyometric berdampak rendah di papan geser, ramah untuk lutut dan pinggul."],
		["Archway & Ladder", "Archway & Ladder", "new-banners/banner-pilates.png",
		 "Mobility and decompression work for shoulders, spine and hips.",
		 "Latihan mobilitas dan dekompresi untuk bahu, tulang belakang, dan pinggul."],
		["Private Session Room", "Ruang Sesi Privat", "facilities/yoga.png",
		 "A closed studio for one-to-one work and post-injury rehabilitation.",
		 "Studio tertutup untuk latihan satu lawan satu dan rehabilitasi pascacedera."],
		["Recovery Lounge", "Lounge Pemulihan", "facilities/recovery-center.png",
		 "Somewhere to sit, stretch and rehydrate before heading back out.",
		 "Tempat untuk duduk, peregangan, dan rehidrasi sebelum kembali beraktivitas."]
	].each_with_index do |(en, id, image, en_desc, id_desc), index|
		fitness_amenity!(gyrotonic, en, id_name: id, en_desc: en_desc, id_desc: id_desc, image: image, position: index + 1)
	end

	fitness_gallery!(gyrotonic, ["new-banners/banner-gyrotonic.png", "facilities/pilates.png",
															 "new-banners/banner-pilates.png", "facilities/yoga.png",
															 "facilities/recovery-center.png", "new-banners/banner-fitness.png"])
end

# ---------------------------------------------------------------------------
# Pilates
# ---------------------------------------------------------------------------
pilates = fitness_facility("Pilates")
if pilates
	fitness_hide_pricing!(pilates)
	fitness_middle_banner!(pilates, "middle-banner-pilates.png")

	fitness_intro!(pilates,
		"Reformer, mat and apparatus all live in the same studio, so a class can use whichever piece suits the work rather than whichever piece is free.",
		"Reformer, matras, dan apparatus berada di studio yang sama, sehingga kelas dapat menggunakan alat yang paling sesuai, bukan sekadar yang sedang kosong.")

	fitness_detail!(pilates, "Class Schedule",
		id_title: "Jadwal Kelas",
		en_body: "Monday – Friday: 06:30 AM, 08:00 AM, 05:00 PM, 06:30 PM\nSaturday – Sunday: 08:00 AM, 09:30 AM, 04:00 PM\n\nReformer classes cap at 8 mats and fill quickly — book at least a day ahead where you can.",
		id_body: "Senin – Jumat: 06.30, 08.00, 17.00, 18.30\nSabtu – Minggu: 08.00, 09.30, 16.00\n\nKelas reformer dibatasi 8 matras dan cepat penuh — sebaiknya pesan setidaknya satu hari sebelumnya.",
		position: 1)

	fitness_detail!(pilates, "Capacity",
		id_title: "Kapasitas",
		en_body: "Max 8 mats per reformer class, 14 per mat class",
		id_body: "Maksimal 8 matras per kelas reformer, 14 per kelas mat",
		position: 2)

	[
		["Drop-In Class", "Kelas Sekali Datang", "06:30 AM – 07:30 PM", "One class, any format", "Satu kelas, format apa pun", "Rp 250.000"],
		["10-Class Pass", "Paket 10 Kelas", "06:30 AM – 07:30 PM", "Valid for 3 months", "Berlaku 3 bulan", "Rp 2.100.000"],
		["Monthly Unlimited", "Bulanan Tanpa Batas", "06:30 AM – 07:30 PM", "Unlimited group classes", "Kelas kelompok tanpa batas", "Rp 2.850.000"],
		["Private Session", "Sesi Privat", "06:30 AM – 07:30 PM", "One-to-one, 55 minutes", "Satu lawan satu, 55 menit", "Rp 600.000"]
	].each_with_index do |(en, id, time, en_access, id_access, price), index|
		fitness_rate!(pilates, en, id_name: id, time: time, en_access: en_access, id_access: id_access, price: price, position: index + 1)
	end

	[
		["Reformer Studio", "Studio Reformer", "new-banners/banner-pilates.png",
		 "Eight reformers with boxes, straps and jump boards for every level.",
		 "Delapan reformer lengkap dengan box, strap, dan jump board untuk semua tingkatan."],
		["Mat Studio", "Studio Matras", "facilities/pilates.png",
		 "A mirrored room for classical mat work and larger group sessions.",
		 "Ruang bercermin untuk latihan mat klasik dan sesi kelompok yang lebih besar."],
		["Cadillac & Tower", "Cadillac & Tower", "facilities/yoga.png",
		 "Spring-assisted apparatus for rehabilitation and advanced repertoire.",
		 "Apparatus berbantuan pegas untuk rehabilitasi dan repertoar tingkat lanjut."],
		["Wunda Chair Corner", "Sudut Wunda Chair", "new-banners/banner-yoga.png",
		 "Compact chair work that builds control through the hips and shoulders.",
		 "Latihan chair yang ringkas untuk membangun kontrol pinggul dan bahu."],
		["Props & Small Equipment", "Props & Alat Kecil", "facilities/lockers.png",
		 "Rings, bands, balls and rollers, all stocked and ready by the door.",
		 "Ring, band, bola, dan roller, semuanya tersedia dan siap di dekat pintu."]
	].each_with_index do |(en, id, image, en_desc, id_desc), index|
		fitness_amenity!(pilates, en, id_name: id, en_desc: en_desc, id_desc: id_desc, image: image, position: index + 1)
	end

	fitness_gallery!(pilates, ["new-banners/banner-pilates.png", "facilities/pilates.png",
														 "facilities/yoga.png", "new-banners/banner-yoga.png",
														 "new-banners/banner-fitness.png", "facilities/recovery-center.png"])
end

# ---------------------------------------------------------------------------
# Yoga
# ---------------------------------------------------------------------------
yoga = fitness_facility("Yoga")
if yoga
	fitness_hide_pricing!(yoga)
	fitness_middle_banner!(yoga, "middle-banner-yoga.png")

	fitness_intro!(yoga,
		"The shala opens onto a shaded deck, so classes move outside whenever the weather is right and the ocean breeze does the cooling.",
		"Shala terbuka ke arah dek yang teduh, sehingga kelas dapat dipindahkan ke luar saat cuaca mendukung dan angin laut menjadi pendinginnya.")

	fitness_detail!(yoga, "Class Schedule",
		id_title: "Jadwal Kelas",
		en_body: "Monday – Friday: 06:30 AM, 09:00 AM, 05:30 PM\nSaturday – Sunday: 07:00 AM, 09:00 AM, 04:30 PM\n\nSunrise classes run on the outdoor deck when conditions allow, and move into the shala in the rain.",
		id_body: "Senin – Jumat: 06.30, 09.00, 17.30\nSabtu – Minggu: 07.00, 09.00, 16.30\n\nKelas matahari terbit diadakan di dek luar bila cuaca memungkinkan, dan dipindahkan ke dalam shala saat hujan.",
		position: 1)

	fitness_detail!(yoga, "Capacity",
		id_title: "Kapasitas",
		en_body: "Max 20 mats indoors, 16 on the deck",
		id_body: "Maksimal 20 matras di dalam, 16 di dek luar",
		position: 2)

	[
		["Drop-In Class", "Kelas Sekali Datang", "06:30 AM – 06:30 PM", "One class, any style", "Satu kelas, gaya apa pun", "Rp 180.000"],
		["10-Class Pass", "Paket 10 Kelas", "06:30 AM – 06:30 PM", "Valid for 3 months", "Berlaku 3 bulan", "Rp 1.500.000"],
		["Monthly Unlimited", "Bulanan Tanpa Batas", "06:30 AM – 06:30 PM", "Unlimited group classes", "Kelas kelompok tanpa batas", "Rp 1.950.000"],
		["Private Session", "Sesi Privat", "06:30 AM – 06:30 PM", "One-to-one, 60 minutes", "Satu lawan satu, 60 menit", "Rp 500.000"]
	].each_with_index do |(en, id, time, en_access, id_access, price), index|
		fitness_rate!(yoga, en, id_name: id, time: time, en_access: en_access, id_access: id_access, price: price, position: index + 1)
	end

	[
		["The Shala", "Shala", "new-banners/banner-yoga.png",
		 "A high-ceilinged practice room with timber floors and full-length shutters.",
		 "Ruang latihan berlangit-langit tinggi dengan lantai kayu dan jendela kayu penuh."],
		["Outdoor Deck", "Dek Luar Ruang", "facilities/yoga.png",
		 "Shaded decking for sunrise and sunset practice, open to the sea breeze.",
		 "Dek beratap teduh untuk latihan matahari terbit dan terbenam, terbuka ke angin laut."],
		["Props Library", "Perpustakaan Props", "facilities/pilates.png",
		 "Bolsters, blocks, straps and blankets, enough for a full class at once.",
		 "Bolster, blok, strap, dan selimut, cukup untuk satu kelas penuh sekaligus."],
		["Meditation Corner", "Sudut Meditasi", "new-banners/banner-spa.png",
		 "A quiet, screened space set aside for seated practice and breathwork.",
		 "Ruang tenang bersekat yang disediakan untuk latihan duduk dan olah napas."],
		["Changing Rooms", "Ruang Ganti", "facilities/lockers.png",
		 "Lockers, showers and towel service directly off the studio entrance.",
		 "Loker, shower, dan layanan handuk tepat di pintu masuk studio."]
	].each_with_index do |(en, id, image, en_desc, id_desc), index|
		fitness_amenity!(yoga, en, id_name: id, en_desc: en_desc, id_desc: id_desc, image: image, position: index + 1)
	end

	fitness_gallery!(yoga, ["new-banners/banner-yoga.png", "facilities/yoga.png",
													"facilities/pilates.png", "new-banners/banner-spa.png",
													"new-banners/banner-pilates.png", "facilities/recovery-center.png"])
end

# ---------------------------------------------------------------------------
# Lap Pool
# ---------------------------------------------------------------------------
lap_pool = fitness_facility("Lap Pool")
if lap_pool
	fitness_hide_pricing!(lap_pool)
	fitness_middle_banner!(lap_pool, "middle-banner-lap-pool.png")

	fitness_intro!(lap_pool,
		"Lanes stay open through the day outside scheduled class hours, with towels, showers and shade all within a few steps of the water.",
		"Lintasan tetap terbuka sepanjang hari di luar jam kelas terjadwal, dengan handuk, shower, dan area teduh hanya beberapa langkah dari kolam.")

	fitness_detail!(lap_pool, "Pool Specifications",
		id_title: "Spesifikasi Kolam",
		en_body: "Pool Dimension:\nLength: 25 Meters (Standard Semi-Olympic Short-Course, ideal for lap training and interval swimming)\nWidth: 10 Meters (Divided into 4 active lanes)\nDepth: Graduated from 1.2 Meters (shallow end for safe turns/starts) to 1.6 Meters (deep end)\nLane Width: 2.3 Meters per lane (provides ample and safe clearance space when passing other swimmers).\n\nWater Quality & Environment:\nWater Temperature: 26°C – 28°C (78°F – 82°F)\nFiltration System: Advanced Eco-Friendly Saltwater Chlorination\nSanitization: Equipped with an automated Dual UV Sterilization system that neutralizes 99.9% of bacteria during every water circulation cycle.",
		id_body: "Dimensi Kolam:\nPanjang: 25 Meter (Standar Semi-Olimpik Short-Course, ideal untuk latihan lap dan renang interval)\nLebar: 10 Meter (Terbagi menjadi 4 lintasan aktif)\nKedalaman: Bertahap dari 1,2 Meter (ujung dangkal untuk start dan putaran yang aman) hingga 1,6 Meter (ujung dalam)\nLebar Lintasan: 2,3 Meter per lintasan (memberi ruang aman yang lapang saat menyalip perenang lain).\n\nKualitas Air & Lingkungan:\nSuhu Air: 26°C – 28°C (78°F – 82°F)\nSistem Filtrasi: Klorinasi Air Garam Ramah Lingkungan\nSanitasi: Dilengkapi sistem Sterilisasi UV Ganda otomatis yang menetralkan 99,9% bakteri pada setiap siklus sirkulasi air.",
		position: 1)

	fitness_detail!(lap_pool, "Operating Hours",
		id_title: "Jam Operasional",
		en_body: "Monday – Friday: 06:00 AM – 07:00 PM\nSaturday – Sunday: 06:00 AM – 07:00 PM\nPublic Holidays: 06:00 AM – 07:00 PM\nLane Note:\nTwo lanes are reserved for squad training on weekday mornings from 06:00 AM to 07:30 AM. The other two stay open for members throughout.",
		id_body: "Senin – Jumat: 06.00 – 19.00\nSabtu – Minggu: 06.00 – 19.00\nHari Libur Nasional: 06.00 – 19.00\nCatatan Lintasan:\nDua lintasan dipesan untuk latihan skuad pada pagi hari kerja pukul 06.00 hingga 07.30. Dua lintasan lainnya tetap terbuka untuk anggota.",
		position: 2)

	[
		["Single Swim", "Renang Sekali Datang", "06:00 AM – 07:00 PM", "Single-day pool access", "Akses kolam satu hari", "Rp 120.000"],
		["10-Swim Pass", "Paket 10 Renang", "06:00 AM – 07:00 PM", "Valid for 3 months", "Berlaku 3 bulan", "Rp 950.000"],
		["Monthly Membership", "Keanggotaan Bulanan", "06:00 AM – 07:00 PM", "Unlimited daily access", "Akses harian tanpa batas", "Rp 550.000"],
		["Yearly Membership", "Keanggotaan Tahunan", "06:00 AM – 07:00 PM", "Unlimited daily access", "Akses harian tanpa batas", "Rp 4.950.000"]
	].each_with_index do |(en, id, time, en_access, id_access, price), index|
		fitness_rate!(lap_pool, en, id_name: id, time: time, en_access: en_access, id_access: id_access, price: price, position: index + 1)
	end

	[
		["Four-Lane 25m Pool", "Kolam 25m Empat Lintasan", "new-banners/banner-lap-pool.png",
		 "Marked lanes and a graduated floor, kept between 26°C and 28°C year round.",
		 "Lintasan bertanda dan dasar bertahap, dijaga pada 26°C hingga 28°C sepanjang tahun."],
		["Poolside Loungers", "Kursi Santai Tepi Kolam", "facilities/swimming-pool.png",
		 "Shaded seating along the long edge, first come first served for members.",
		 "Tempat duduk teduh di sisi panjang kolam, tersedia bagi anggota sesuai kedatangan."],
		["Towel Service", "Layanan Handuk", "facilities/lockers.png",
		 "Fresh towels handed out at the gate and collected on your way back through.",
		 "Handuk bersih dibagikan di pintu masuk dan diambil kembali saat Anda keluar."],
		["Outdoor Showers", "Shower Luar Ruang", "facilities/recovery-center.png",
		 "Rinse stations at both ends of the pool, plus full changing rooms indoors.",
		 "Stasiun bilas di kedua ujung kolam, ditambah ruang ganti lengkap di dalam."],
		["Poolside Bar", "Bar Tepi Kolam", "beach_club.png",
		 "Cold drinks, coffee and a short menu, served without leaving the water's edge.",
		 "Minuman dingin, kopi, dan menu ringkas, disajikan tanpa perlu meninggalkan tepi kolam."]
	].each_with_index do |(en, id, image, en_desc, id_desc), index|
		fitness_amenity!(lap_pool, en, id_name: id, en_desc: en_desc, id_desc: id_desc, image: image, position: index + 1)
	end

	fitness_gallery!(lap_pool, ["new-banners/banner-lap-pool.png", "facilities/swimming-pool.png",
															"new-banners/banner-beach-club.png", "beach_club.png",
															"facilities/recovery-center.png", "new-banners/banner-fitness.png"])
end
