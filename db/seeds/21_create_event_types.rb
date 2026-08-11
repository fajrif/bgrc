# Event types shown on /events (image-top, text-below cards), on the homepage's
# Events accordion (home/_event_types.html.erb) and on a page of their own at
# /events/<slug> — one shared source of truth for all three. Idempotent:
# upserts by English name, never deletes.
puts "create event types"

EVENT_TYPE_IMAGES = Rails.root.join("vendor/assets/images")

# Writes a slug for the locale in effect. It needs a save of its own, because
# friendly_id regenerates the slug from the name whenever the name changed and
# would overwrite an explicit slug assigned in that same save.
def event_type_slug!(event_type, slug)
	return if slug.blank? || event_type.slug == slug
	event_type.slug = slug
	event_type.save!
end

def upsert_event_type!(en_name, id_name:, en_desc:, id_desc:, en_body:, id_body:,
											 image:, position:, slug: nil, id_slug: nil, gallery: [])
	event_type = EventType.find_by("name @> ?", { en: en_name }.to_json) || EventType.new

	event_type.name = en_name
	event_type.short_description = en_desc
	event_type.description = en_body
	event_type.position = position
	if !event_type.image.attached?
		event_type.image.attach(io: EVENT_TYPE_IMAGES.join(image).open, filename: File.basename(image))
	end
	event_type.save!
	event_type_slug!(event_type, slug)

	Mobility.with_locale(:id) {
		event_type.name = id_name
		event_type.short_description = id_desc
		event_type.description = id_body
		event_type.save!
		event_type_slug!(event_type, id_slug)
	}

	if gallery.any? && !event_type.images.attached?
		gallery.each do |path|
			event_type.images.attach(io: EVENT_TYPE_IMAGES.join(path).open, filename: File.basename(path))
		end
	end

	puts "Event type: #{event_type.name}"
	event_type
end

upsert_event_type!(
	"Weddings",
	id_name: "Pernikahan",
	slug: "weddings", id_slug: "pernikahan",
	en_desc: "Say \"I do\" against a backdrop of manicured greens and ocean breeze. Our team crafts bespoke wedding experiences from intimate ceremonies to grand receptions.",
	id_desc: "Ucapkan \"Saya bersedia\" dengan latar hamparan hijau dan angin laut. Tim kami merancang pengalaman pernikahan khusus, dari upacara intim hingga resepsi megah.",
	en_body: "Ceremonies can be held on the lawn overlooking the course, on the beach as the sun goes down, or indoors if the season calls for it — and the reception can move somewhere different again once the vows are done.\n\nOur kitchens build the menu around you rather than handing over a fixed package, whether that means a seated dinner, a standing reception with canapes, or something that runs from one into the other as the evening goes on. Wine pairings, cocktail hours and late-night bites are all arranged in the same conversation.\n\nMost couples start planning with us six to twelve months out, though shorter timelines are possible when the calendar allows. Getting-ready suites, guest accommodation and transport can all be folded into the same booking.",
	id_body: "Upacara dapat digelar di halaman dengan pemandangan lapangan, di tepi pantai saat matahari terbenam, atau di dalam ruangan bila musim menghendaki — dan resepsi dapat berpindah ke tempat lain setelah janji suci diucapkan.\n\nDapur kami menyusun menu sesuai keinginan Anda, bukan sekadar menyodorkan paket tetap, baik itu jamuan duduk, resepsi berdiri dengan canape, atau perpaduan keduanya sepanjang malam. Padanan anggur, cocktail hour, dan hidangan larut malam diatur dalam percakapan yang sama.\n\nSebagian besar pasangan mulai merencanakan bersama kami enam hingga dua belas bulan sebelumnya, meski jadwal yang lebih singkat tetap memungkinkan bila kalender mengizinkan. Ruang persiapan, akomodasi tamu, dan transportasi dapat disatukan dalam pemesanan yang sama.",
	image: "beach_club.png",
	position: 1
)

upsert_event_type!(
	"Corporate Events",
	id_name: "Acara Korporat",
	slug: "corporate", id_slug: "korporat",
	en_desc: "Impress clients and reward teams with golf days, tournaments, conferences and team-building sessions supported by full-service catering and event planning.",
	id_desc: "Kesankan klien dan apresiasi tim Anda dengan golf day, turnamen, konferensi, dan sesi team-building yang didukung layanan katering dan perencanaan acara penuh.",
	en_body: "A corporate booking here can be as simple as a shotgun-start golf day with lunch afterwards, or as involved as a multi-day offsite using the meeting rooms in the morning and the courts, course and beach club through the afternoon.\n\nTournament formats, scoring, prize-giving and hosting are all handled by our team, so nobody from your side spends the day running the event instead of attending it. Catering runs from working breakfasts through to a full awards dinner.\n\nWe can hold the whole property exclusively for larger groups, and quieter weekday slots are usually available at short notice for smaller sessions.",
	id_body: "Pemesanan korporat di sini bisa sesederhana golf day dengan shotgun start dan makan siang setelahnya, atau sekompleks offsite beberapa hari yang memanfaatkan ruang rapat di pagi hari serta lapangan, kursus, dan beach club sepanjang sore.\n\nFormat turnamen, penilaian, pembagian hadiah, dan pembawa acara ditangani tim kami, sehingga tidak ada dari pihak Anda yang harus menjalankan acara alih-alih menikmatinya. Katering tersedia mulai dari working breakfast hingga jamuan penghargaan lengkap.\n\nKami dapat menyediakan seluruh properti secara eksklusif untuk kelompok besar, dan slot hari kerja yang lebih sepi umumnya tersedia dalam waktu singkat untuk sesi kecil.",
	image: "banners/banner-events.png",
	position: 2
)

upsert_event_type!(
	"Private Celebrations",
	id_name: "Perayaan Pribadi",
	slug: "private-celebrations", id_slug: "perayaan-pribadi",
	en_desc: "Birthdays, anniversaries and milestone gatherings — celebrate in style with flexible venues, curated menus and a setting your guests will never forget.",
	id_desc: "Ulang tahun, hari jadi, dan momen penting lainnya — rayakan dengan gaya di tempat yang fleksibel, menu pilihan, dan suasana yang tak terlupakan bagi tamu Anda.",
	en_body: "Smaller gatherings suit the private dining rooms, where a single long table and a set menu keep the evening easy. Larger parties take over the beach club or the terrace, with a bar, live music and space for people to move between the two.\n\nMenus are built around what the occasion calls for rather than a fixed list — a tasting dinner for twelve and a standing party for a hundred are planned the same way, just at different scales.\n\nBookings for private celebrations are usually confirmed two to four weeks ahead, and our coordinator will walk the space with you beforehand so you know exactly how the night will run.",
	id_body: "Pertemuan kecil cocok di ruang makan privat, di mana satu meja panjang dan menu set membuat malam terasa ringan. Pesta yang lebih besar dapat mengambil alih beach club atau teras, lengkap dengan bar, musik langsung, dan ruang bagi tamu untuk berpindah di antara keduanya.\n\nMenu disusun sesuai kebutuhan acara, bukan dari daftar tetap — jamuan pencicipan untuk dua belas orang dan pesta berdiri untuk seratus orang direncanakan dengan cara yang sama, hanya berbeda skala.\n\nPemesanan perayaan pribadi umumnya dikonfirmasi dua hingga empat minggu sebelumnya, dan koordinator kami akan meninjau lokasi bersama Anda agar Anda tahu persis bagaimana malam itu akan berjalan.",
	image: "resto/mezzaluna.png",
	position: 3
)
