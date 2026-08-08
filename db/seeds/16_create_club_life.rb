# Club Life — the public menu tree, stored as a Facility hierarchy.
# Re-uses the facilities that already exist (renaming/re-parenting them in place)
# and only creates the nodes that have no record yet. Safe to re-run.
puts "create club life sections"

CLUB_LIFE_IMAGES = Rails.root.join("vendor/assets/images")

def club_life_find(en_name)
	Facility.find_by("name @> ?", { en: en_name }.to_json)
end

# Upserts one node of the tree. `rename_from` lets an existing facility be adopted
# under its Club Life name instead of creating a near-duplicate record.
# `replace_image:` purges whatever image is already attached first — normally
# an admin edit should win over the seed, but a few root sections still carry
# a placeholder photo that a real one needs to replace outright.
def club_life_node!(en_name, attrs: {}, id: {}, image: nil, gallery: [], rename_from: nil, replace_image: false)
	old_record = rename_from ? club_life_find(rename_from) : nil
	record     = club_life_find(en_name)

	if old_record && record && old_record.id != record.id
		# 06_create_facilities.rb doesn't know `rename_from` is the same
		# facility under an old name, so on a database that still has the old
		# name it creates a fresh row instead of finding this one — leaving a
		# duplicate that would otherwise crash the rename below on a uniqueness
		# violation. Drop the stale pre-rename record and keep the one already
		# sitting at the new name.
		puts "Club Life: deleting duplicate #{old_record.name.inspect} (id #{old_record.id}), keeping #{record.name.inspect} (id #{record.id})"
		old_record.destroy
	elsif old_record
		record = old_record
	end

	record ||= Facility.new

	record.assign_attributes(attrs.merge(name: en_name))
	if image.present?
		record.image.purge if replace_image && record.image.attached?
		if !record.image.attached?
			record.image.attach(io: CLUB_LIFE_IMAGES.join(image).open, filename: File.basename(image))
		end
	end
	record.save!

	Mobility.with_locale(:id) do
		record.name = id[:name] if id[:name].present?
		record.short_description = id[:short_description] if id[:short_description].present?
		record.description = id[:description] if id[:description].present?
		record.cta_label = id[:cta_label] if id[:cta_label].present?
		record.save!
	end

	if gallery.any? && !record.images.attached?
		gallery.each do |path|
			record.images.attach(io: CLUB_LIFE_IMAGES.join(path).open, filename: File.basename(path))
		end
	end

	puts "Club Life: #{record.name}"
	record
end

golf_sport       = Sport.find_by(name: "Golf")
tennis_sport     = Sport.find_by(name: "Tennis")
padel_sport      = Sport.find_by(name: "Padel")
pickleball_sport = Sport.find_by(name: "Pickleball")

# ---------------------------------------------------------------- GOLF
golf = club_life_node!(
	"Golf",
	attrs: {
		club_life: true, position: 1, parent_id: nil, sport_id: golf_sport&.id,
		cta_label: "Book Tee Time", cta_url: "/golf",
		short_description: "A coastal course at Tuban playable as nine or eighteen holes, with tee times released daily and green fees set per player.",
		description: "Our course runs along the coast at Tuban and can be played as a nine or an eighteen hole round. Tee times are released on a rolling daily basis and spaced at ten minute intervals, with a maximum of four players per group, so the course never feels crowded.\n\nGreen fees are charged per player and vary between weekdays and weekends. Golf carts, buggies, caddies and club rental can all be added to your booking when you reserve your tee time, so you can arrive with nothing but your shoes."
	},
	id: {
		name: "Golf",
		short_description: "Lapangan tepi pantai di Tuban yang dapat dimainkan sembilan atau delapan belas hole, dengan tee time yang dibuka setiap hari dan green fee per pemain.",
		description: "Lapangan kami membentang di tepi pantai Tuban dan dapat dimainkan dalam sembilan atau delapan belas hole. Tee time dibuka setiap hari dengan jarak sepuluh menit dan maksimal empat pemain per grup, sehingga lapangan tidak pernah terasa padat.\n\nGreen fee dihitung per pemain dan berbeda antara hari kerja dan akhir pekan. Golf cart, buggy, caddie, serta penyewaan stik dapat ditambahkan saat Anda memesan tee time.",
		cta_label: "Pesan Tee Time"
	},
	image: "sports/golf.png"
)

club_life_node!(
	"Golf Course",
	attrs: {
		club_life: false, parent_id: golf.id, position: 1, sport_id: golf_sport&.id,
		cta_label: "Book Tee Time", cta_url: "/golf",
		short_description: "Nine or eighteen holes, ten minute tee intervals, up to four players per group.",
		description: "Book a tee time online and choose your round length at checkout. Carts, buggies, caddies and club rental are available as add-ons, and green fees are shown per player before you confirm."
	},
	id: {
		name: "Lapangan Golf",
		short_description: "Sembilan atau delapan belas hole, interval tee sepuluh menit, hingga empat pemain per grup.",
		description: "Pesan tee time secara online dan pilih panjang permainan saat checkout. Cart, buggy, caddie, dan penyewaan stik tersedia sebagai tambahan, dan green fee ditampilkan per pemain sebelum Anda mengonfirmasi.",
		cta_label: "Pesan Tee Time"
	}
)

club_life_node!(
	"Golf Lessons & Academy",
	attrs: {
		club_life: false, parent_id: golf.id, position: 2,
		cta_label: "View Classes", cta_url: "/group_classes",
		short_description: "Coaching for players at every stage, from first grip to competitive play.",
		description: "Lessons are run by our resident coaching team and can be taken privately, semi-privately or as part of a small group. Sessions cover the full game: driving, irons, short game and putting, with course play once the fundamentals are in place."
	},
	id: {
		name: "Les Golf & Akademi",
		short_description: "Pelatihan untuk pemain di setiap tahap, dari pegangan pertama hingga permainan kompetitif.",
		description: "Les dijalankan oleh tim pelatih kami dan dapat diambil secara privat, semi-privat, atau dalam grup kecil. Sesi mencakup keseluruhan permainan: driving, iron, short game, dan putting.",
		cta_label: "Lihat Kelas"
	},
	image: "sports/golf/gallery-3.png", # placeholder — replace with an academy photo via admin
	gallery: ["sports/golf/gallery-3.png", "sports/golf/gallery-1.png", "sports/golf/gallery-4.png",
						"sports/golf/gallery-6.png", "sports/golf/gallery-2.png", "sports/golf/gallery-5.png"]
)

club_life_node!(
	"Driving Range",
	attrs: {
		club_life: false, parent_id: golf.id, position: 3,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Warm up before your round or work through a bucket at your own pace.",
		description: "The range sits alongside the first tee and is open through the day. Clubs are available to rent at the pro shop if you would rather travel light, and our coaches are on hand if you want a few pointers between buckets."
	},
	id: {
		name: "Driving Range",
		short_description: "Pemanasan sebelum bermain atau berlatih sesuai ritme Anda sendiri.",
		description: "Driving range berada di samping tee pertama dan buka sepanjang hari. Stik dapat disewa di pro shop, dan pelatih kami siap membantu jika Anda membutuhkan arahan.",
		cta_label: "Hubungi Kami"
	},
	image: "sports/golf/gallery-5.png", # placeholder — replace with a driving range photo via admin
	gallery: ["sports/golf/gallery-5.png", "sports/golf/gallery-2.png", "sports/golf/gallery-6.png",
						"sports/golf/gallery-4.png", "sports/golf/gallery-1.png", "sports/golf/gallery-3.png"]
)

# ------------------------------------------------------- RACQUET SPORTS
racquet = club_life_node!(
	"Racquet Sports",
	attrs: {
		club_life: true, position: 2, parent_id: nil, sport_id: nil,
		cta_label: "Explore Classes", cta_url: "/group_classes",
		short_description: "Tennis, padel and pickleball courts, with coaching delivered in partnership with MITS Academy.",
		description: "Three racquet sports share the same corner of the club, so you can move between them as easily as changing shoes. Courts can be booked by the hour, and coached sessions run as private lessons, group classes and social classes through the week.\n\nOur coaching programme is delivered in partnership with MITS Academy, whose coaches work with players from first-time juniors through to competitive adults."
	},
	id: {
		name: "Olahraga Raket",
		short_description: "Lapangan tenis, padel, dan pickleball, dengan pelatihan bersama MITS Academy.",
		description: "Tiga olahraga raket berbagi sudut klub yang sama, sehingga Anda dapat berpindah di antaranya semudah mengganti sepatu. Lapangan dapat dipesan per jam, dan sesi berpelatih tersedia sebagai les privat, kelas grup, dan kelas sosial sepanjang minggu.\n\nProgram pelatihan kami dijalankan bersama MITS Academy.",
		cta_label: "Lihat Kelas"
	},
	image: "banners/banner-tennis.png",
	gallery: ["sports/tennis/gallery-1.png", "sports/padel/gallery-1.png", "sports/pickleball/gallery-1.png",
						"sports/tennis/gallery-4.png", "sports/padel/gallery-3.png", "sports/pickleball/gallery-2.png"]
)

tennis = club_life_node!(
	"Tennis",
	rename_from: "Tennis Court",
	attrs: {
		club_life: false, parent_id: racquet.id, position: 1, sport_id: tennis_sport&.id,
		cta_label: "Book a Court", cta_url: "/search?sport_id=#{tennis_sport&.id}",
		short_description: "Private lessons, adult and junior group classes, and weekly social classes.",
		description: "Tennis is the busiest of our racquet programmes. Alongside hourly court bookings we run private and semi-private lessons, adult and child group classes, and two weekly social classes for members who would rather just turn up and play."
	},
	id: {
		name: "Tenis",
		short_description: "Les privat, kelas grup dewasa dan anak, serta kelas sosial mingguan.",
		description: "Tenis adalah program raket kami yang paling sibuk. Selain penyewaan lapangan per jam, kami menjalankan les privat dan semi-privat, kelas grup dewasa dan anak, serta dua kelas sosial mingguan.",
		cta_label: "Pesan Lapangan"
	}
)

padel = club_life_node!(
	"Padel",
	rename_from: "Padel Court",
	attrs: {
		club_life: false, parent_id: racquet.id, position: 2, sport_id: padel_sport&.id,
		cta_label: "Book a Court", cta_url: "/search?sport_id=#{padel_sport&.id}",
		short_description: "Enclosed courts, quick to learn, and a weekly ladies' night.",
		description: "Padel is the fastest game to pick up of the three — the walls keep the ball in play and rallies last longer, which makes it forgiving for newcomers. Private sessions are available, and our ladies' night runs every Friday afternoon."
	},
	id: {
		name: "Padel",
		short_description: "Lapangan tertutup, cepat dipelajari, dengan ladies' night mingguan.",
		description: "Padel adalah permainan yang paling cepat dipelajari di antara ketiganya — dinding menjaga bola tetap dalam permainan sehingga reli berlangsung lebih lama. Sesi privat tersedia, dan ladies' night kami berlangsung setiap Jumat sore.",
		cta_label: "Pesan Lapangan"
	}
)

pickleball = club_life_node!(
	"Pickleball",
	rename_from: "Pickleball Court",
	attrs: {
		club_life: false, parent_id: racquet.id, position: 3, sport_id: pickleball_sport&.id,
		cta_label: "Book a Court", cta_url: "/search?sport_id=#{pickleball_sport&.id}",
		short_description: "Short court, light paddle, and the easiest way into racquet sports.",
		description: "Pickleball uses a smaller court and a solid paddle, so points are quick and the learning curve is short. It has become the club's most sociable racquet sport, and courts can be booked by the hour like any other."
	},
	id: {
		name: "Pickleball",
		short_description: "Lapangan pendek, raket ringan, dan cara termudah masuk ke olahraga raket.",
		description: "Pickleball menggunakan lapangan yang lebih kecil dan raket padat, sehingga poin berlangsung cepat dan mudah dipelajari. Lapangan dapat dipesan per jam seperti olahraga lainnya.",
		cta_label: "Pesan Lapangan"
	}
)

# -------------------------------------------- RACQUET SPORT FACILITIES
# The venues listed on each sport page have no page of their own — they exist
# only to be shown as a card on their sport's page — so they're `Amenity`
# rows (belongs_to :facility), not `Facility` rows. Earlier seed runs created
# them as Facility grandchildren before that split existed; remove those
# stray rows so the facilities table only ever holds records with a real page.
%w[
	Tennis\ Centre\ Court Tennis\ Practice\ Wall Tennis\ Floodlit\ Courts
	Tennis\ Pro\ Shop\ Counter Tennis\ Player\ Lounge
	Padel\ Glass\ Courts Padel\ Viewing\ Deck Padel\ Equipment\ Hire
	Pickleball\ Courts Pickleball\ Social\ Area Pickleball\ Paddle\ Hire
].each { |old_name| club_life_find(old_name)&.destroy }

def amenity!(facility, en_name, en_desc:, id_name:, id_desc:, image:, position:)
	record = Amenity.find_by("name @> ?", { en: en_name }.to_json) || Amenity.new
	record.facility = facility
	record.position = position
	record.name = en_name
	record.short_description = en_desc
	if image.present? && !record.image.attached?
		record.image.attach(io: CLUB_LIFE_IMAGES.join(image).open, filename: File.basename(image))
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

racquet_facilities = [
	{ parent: tennis, sport_slug: "tennis", items: [
		{ en: "Tennis Centre Court", id_name: "Lapangan Utama Tenis", photo: "gallery-1.png",
			en_desc: "Our show court, with tiered seating for club tournaments and finals nights.",
			id_desc: "Lapangan utama kami, dengan tribun bertingkat untuk turnamen klub dan malam final." },
		{ en: "Tennis Practice Wall", id_name: "Dinding Latihan Tenis", photo: "gallery-2.png",
			en_desc: "A full-height rebound wall for solo drilling, open whenever the courts are.",
			id_desc: "Dinding pantul setinggi penuh untuk latihan mandiri, buka selama lapangan beroperasi." },
		{ en: "Tennis Floodlit Courts", id_name: "Lapangan Tenis Bercahaya", photo: "gallery-3.png",
			en_desc: "Evening play under full floodlighting, bookable through to close.",
			id_desc: "Bermain malam hari dengan pencahayaan penuh, dapat dipesan hingga tutup." },
		{ en: "Tennis Pro Shop Counter", id_name: "Konter Pro Shop Tenis", photo: "gallery-4.png",
			en_desc: "Restringing, grips and demo racquets, with same-day turnaround on most jobs.",
			id_desc: "Pemasangan senar, grip, dan raket demo, sebagian besar selesai di hari yang sama." },
		{ en: "Tennis Player Lounge", id_name: "Lounge Pemain Tenis", photo: "gallery-5.png",
			en_desc: "Shaded seating beside the courts for warming up, cooling down and waiting on a match.",
			id_desc: "Tempat duduk teduh di sisi lapangan untuk pemanasan, pendinginan, dan menunggu pertandingan." }
	] },
	{ parent: padel, sport_slug: "padel", items: [
		{ en: "Padel Glass Courts", id_name: "Lapangan Kaca Padel", photo: "gallery-1.png",
			en_desc: "Fully enclosed panoramic courts, the standard format for competitive padel.",
			id_desc: "Lapangan panoramik tertutup penuh, format standar untuk padel kompetitif." },
		{ en: "Padel Viewing Deck", id_name: "Dek Penonton Padel", photo: "gallery-3.png",
			en_desc: "Raised seating along the glass, where most of the club's padel socials end up.",
			id_desc: "Tempat duduk tinggi di sepanjang kaca, tempat berkumpulnya acara sosial padel klub." },
		{ en: "Padel Equipment Hire", id_name: "Sewa Peralatan Padel", photo: "gallery-4.png",
			en_desc: "Paddles and balls available at the desk, so first-timers can play without buying kit.",
			id_desc: "Raket dan bola tersedia di meja resepsionis, sehingga pemula dapat bermain tanpa membeli perlengkapan." }
	] },
	{ parent: pickleball, sport_slug: "pickleball", items: [
		{ en: "Pickleball Courts", id_name: "Lapangan Pickleball", photo: "gallery-1.png",
			en_desc: "Four dedicated courts, lined and netted to tournament specification.",
			id_desc: "Empat lapangan khusus, dengan garis dan net sesuai spesifikasi turnamen." },
		{ en: "Pickleball Social Area", id_name: "Area Sosial Pickleball", photo: "gallery-2.png",
			en_desc: "Courtside tables where round-robin sessions regroup between games.",
			id_desc: "Meja di tepi lapangan tempat sesi round-robin berkumpul di antara pertandingan." },
		{ en: "Pickleball Paddle Hire", id_name: "Sewa Raket Pickleball", photo: "gallery-3.png",
			en_desc: "Loan paddles and balls for anyone trying the sport for the first time.",
			id_desc: "Peminjaman raket dan bola bagi siapa saja yang baru mencoba olahraga ini." }
	] }
]

racquet_facilities.each do |group|
	next if group[:parent].blank?

	group[:items].each_with_index do |item, index|
		amenity!(
			group[:parent],
			item[:en],
			en_desc: item[:en_desc],
			id_name: item[:id_name],
			id_desc: item[:id_desc],
			image: "sports/#{group[:sport_slug]}/#{item[:photo]}",
			position: index + 1
		)
	end
end

# ------------------------------------------------------------- FITNESS
fitness = club_life_node!(
	"Fitness",
	attrs: {
		club_life: true, position: 3, parent_id: nil, sport_id: nil,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "A full gym floor plus yoga, pilates and the pool, open through the day.",
		description: "The gym floor covers free weights, resistance machines and cardio, with space to train without waiting for equipment. Yoga and pilates run in the studio alongside it, and the pool is open for lap swimming outside of class hours.\n\nMembership includes gym access; class schedules and personal training are arranged through the front desk."
	},
	id: {
		name: "Kebugaran",
		short_description: "Area gym lengkap ditambah yoga, pilates, dan kolam renang, buka sepanjang hari.",
		description: "Area gym mencakup beban bebas, mesin resistensi, dan kardio, dengan ruang yang cukup untuk berlatih tanpa mengantre. Yoga dan pilates berlangsung di studio di sebelahnya, dan kolam renang terbuka untuk berenang di luar jam kelas.\n\nKeanggotaan mencakup akses gym; jadwal kelas dan personal training diatur melalui front desk.",
		cta_label: "Hubungi Kami"
	},
	image: "fitness.png",
	replace_image: true,
	gallery: ["facilities/gym.png", "facilities/pilates.png", "facilities/yoga.png", "facilities/swimming-pool.png"]
)

club_life_node!(
	"Gym",
	rename_from: "GYM",
	attrs: {
		club_life: false, parent_id: fitness.id, position: 1,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Free weights, resistance machines and cardio, open through the day.",
		description: "The gym floor is laid out so free weights, resistance machines and cardio each have their own space — there is always somewhere to train without waiting on equipment. Staff are on hand during peak hours, and personal training can be arranged through the front desk."
	},
	id: {
		name: "Gym",
		short_description: "Beban bebas, mesin resistensi, dan kardio, buka sepanjang hari.",
		description: "Area gym ditata sehingga beban bebas, mesin resistensi, dan kardio masing-masing memiliki ruang tersendiri — selalu ada tempat untuk berlatih tanpa menunggu alat. Staf siap membantu pada jam sibuk, dan personal training dapat diatur melalui front desk.",
		cta_label: "Hubungi Kami"
	}
)

club_life_node!(
	"Gyrotonic",
	attrs: {
		club_life: false, parent_id: fitness.id, position: 2,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Machine-based movement work that builds strength without the strain.",
		description: "Gyrotonic sessions use the studio's specialist equipment to move the spine and joints through their full range, building strength and coordination with far less strain than a conventional weights session. Sessions are one-on-one and booked through the front desk."
	},
	id: {
		name: "Gyrotonic",
		short_description: "Latihan gerak berbasis alat yang membangun kekuatan tanpa membebani tubuh.",
		description: "Sesi Gyrotonic menggunakan alat khusus studio untuk menggerakkan tulang belakang dan sendi secara menyeluruh, membangun kekuatan dan koordinasi dengan beban yang jauh lebih ringan dibanding latihan beban biasa. Sesi bersifat privat dan dipesan melalui front desk.",
		cta_label: "Hubungi Kami"
	},
	image: "facilities/pilates.png" # placeholder — replace with a Gyrotonic studio photo via admin
)

club_life_node!(
	"Pilates",
	attrs: {
		club_life: false, parent_id: fitness.id, position: 3,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Studio reformer and mat classes for core strength and posture.",
		description: "Our pilates studio runs reformer and mat sessions through the day, in small groups so instructors can correct form as you go. It is a popular pairing with the gym for members building strength without adding bulk."
	},
	id: {
		name: "Pilates",
		short_description: "Kelas reformer dan mat untuk kekuatan inti tubuh dan postur.",
		description: "Studio pilates kami menjalankan sesi reformer dan mat sepanjang hari, dalam grup kecil sehingga instruktur dapat mengoreksi gerakan Anda. Populer dipadukan dengan gym bagi anggota yang membangun kekuatan tanpa menambah massa otot.",
		cta_label: "Hubungi Kami"
	}
)

club_life_node!(
	"Yoga",
	attrs: {
		club_life: false, parent_id: fitness.id, position: 4,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Daily classes from gentle flow to power yoga, in a dedicated studio.",
		description: "Classes run daily in the studio, spanning gentle flow, power yoga and everything in between, so members can find a pace that suits them. Mats and props are provided — just bring yourself."
	},
	id: {
		name: "Yoga",
		short_description: "Kelas harian dari flow ringan hingga power yoga, di studio khusus.",
		description: "Kelas berlangsung setiap hari di studio, mencakup flow ringan, power yoga, dan berbagai variasi di antaranya, sehingga anggota dapat menemukan ritme yang sesuai. Matras dan perlengkapan disediakan — Anda tinggal datang.",
		cta_label: "Hubungi Kami"
	}
)

club_life_node!(
	"Lap Pool",
	rename_from: "Swimming Pool",
	attrs: {
		club_life: false, parent_id: fitness.id, position: 5,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Open for lap swimming outside of class hours.",
		description: "The lap pool sits alongside the gym and is open for members through the day, outside of any scheduled class hours. Lanes are marked for continuous laps, and towels are available at the front desk."
	},
	id: {
		name: "Kolam Renang",
		short_description: "Terbuka untuk berenang di luar jam kelas.",
		description: "Kolam renang berada di samping gym dan terbuka bagi anggota sepanjang hari, di luar jadwal kelas. Jalur ditandai untuk renang berkelanjutan, dan handuk tersedia di front desk.",
		cta_label: "Hubungi Kami"
	}
)

# ---------------------------------------------------------- BEACH CLUB
club_life_node!(
	"Beach Club",
	attrs: {
		club_life: true, position: 4, parent_id: nil, sport_id: nil,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Loungers, shade and the pool deck, a short walk from the courts.",
		description: "The beach club is where the day slows down. Loungers and shade run along the pool deck, food and drinks come across from the restaurant, and it stays open into the evening.\n\nIt is also the part of the club most often booked for private events — get in touch if you would like to hold something here."
	},
	id: {
		name: "Beach Club",
		short_description: "Kursi santai, area teduh, dan pool deck, hanya beberapa langkah dari lapangan.",
		description: "Beach club adalah tempat hari berjalan lebih lambat. Kursi santai dan area teduh membentang di sepanjang pool deck, makanan dan minuman diantar dari restoran, dan tempat ini buka hingga malam.\n\nArea ini juga paling sering dipesan untuk acara privat — hubungi kami jika Anda ingin mengadakan acara di sini.",
		cta_label: "Hubungi Kami"
	},
	image: "beach_club.png",
	replace_image: true,
	gallery: ["beach_club.png", "new-banners/banner-beach-club.png", "facilities/swimming-pool.png",
						"new-banners/banner-lap-pool.png", "resto/mezzaluna.png", "banners/banner-events.png"]
)

# ------------------------------------------------------- SPA + WELLNESS
spa = club_life_node!(
	"Spa + Wellness",
	attrs: {
		club_life: true, position: 5, parent_id: nil, sport_id: nil,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Treatment rooms, recovery facilities and longevity programmes under one roof.",
		description: "Wellness at the club covers three related things: traditional spa treatments, physical recovery for members training hard, and longer-term programmes aimed at how well you age.\n\nTreatments are delivered by our specialist team and booked through the front desk. If you are unsure which of the three you need, our specialists will talk it through with you first."
	},
	id: {
		name: "Spa + Wellness",
		short_description: "Ruang perawatan, fasilitas pemulihan, dan program longevity dalam satu atap.",
		description: "Wellness di klub kami mencakup tiga hal yang saling berkaitan: perawatan spa tradisional, pemulihan fisik untuk anggota yang berlatih keras, dan program jangka panjang untuk kualitas penuaan.\n\nPerawatan dijalankan oleh tim spesialis kami dan dipesan melalui front desk.",
		cta_label: "Hubungi Kami"
	},
	image: "spa_wellness.png",
	replace_image: true,
	gallery: ["facilities/yoga.png", "facilities/pilates.png", "facilities/recovery-center.png"]
)

club_life_node!(
	"Spa",
	attrs: {
		club_life: false, parent_id: spa.id, position: 1,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Massage and traditional treatments in quiet rooms away from the courts.",
		description: "Our treatment rooms sit away from the busier side of the club. Sessions run from short massages between a round and dinner through to longer treatments, and can be booked for one or two people."
	},
	id: {
		name: "Spa",
		short_description: "Pijat dan perawatan tradisional di ruang tenang jauh dari lapangan.",
		description: "Ruang perawatan kami berada jauh dari sisi klub yang lebih ramai. Sesi tersedia mulai dari pijat singkat hingga perawatan yang lebih panjang, dan dapat dipesan untuk satu atau dua orang.",
		cta_label: "Hubungi Kami"
	},
	image: "facilities/pilates.png" # placeholder — replace with a spa treatment photo via admin
	# gallery lives in 23_create_spa_pages.rb, which uses the real spa photography
)

club_life_node!(
	"Recovery",
	rename_from: "Sauna",
	attrs: {
		club_life: false, parent_id: spa.id, position: 2,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Sauna and recovery facilities for members training through the week.",
		description: "The recovery centre is built around the members who train hardest — sauna, stretching space and hands-on recovery work between sessions. It is the quickest way to get back onto the court or the course the following morning."
	},
	id: {
		name: "Pemulihan",
		short_description: "Sauna dan fasilitas pemulihan untuk anggota yang berlatih sepanjang minggu.",
		description: "Pusat pemulihan dirancang untuk anggota yang berlatih paling keras — sauna, ruang peregangan, dan penanganan pemulihan di antara sesi latihan.",
		cta_label: "Hubungi Kami"
	}
	# gallery lives in 23_create_spa_pages.rb, which uses the real spa photography
)

club_life_node!(
	"Anti Aging",
	attrs: {
		club_life: false, parent_id: spa.id, position: 3,
		cta_label: "Enquire", cta_url: "/contact",
		short_description: "Longer-term programmes built around how well you age, not just how you feel today.",
		description: "Our anti-aging programmes are planned over months rather than single visits, combining treatments with movement and recovery work. Every programme starts with a consultation with one of our specialists so the plan matches where you actually are."
	},
	id: {
		name: "Anti Aging",
		short_description: "Program jangka panjang yang dibangun untuk kualitas penuaan, bukan sekadar hari ini.",
		description: "Program anti-aging kami direncanakan dalam hitungan bulan, menggabungkan perawatan dengan latihan gerak dan pemulihan. Setiap program dimulai dengan konsultasi bersama salah satu spesialis kami.",
		cta_label: "Hubungi Kami"
	},
	image: "facilities/yoga.png" # placeholder — replace with an anti-aging photo via admin
	# gallery lives in 23_create_spa_pages.rb, which uses the real spa photography
)

puts "Club Life sections: #{Facility.club_life_roots.count} roots, #{Facility.where.not(parent_id: nil).count} children"
