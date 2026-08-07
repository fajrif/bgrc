# Event types shown on /events (image-top, text-below cards) and on the
# homepage's Events accordion (home/_event_types.html.erb) — one shared
# source of truth for both places. Idempotent: upserts by English name,
# never deletes.
puts "create event types"

EVENT_TYPE_IMAGES = Rails.root.join("vendor/assets/images")

def upsert_event_type!(en_name, id_name:, en_desc:, id_desc:, image:, position:)
	event_type = EventType.find_by("name @> ?", { en: en_name }.to_json) || EventType.new

	event_type.name = en_name
	event_type.short_description = en_desc
	event_type.position = position
	if !event_type.image.attached?
		event_type.image.attach(io: EVENT_TYPE_IMAGES.join(image).open, filename: File.basename(image))
	end
	event_type.save!

	Mobility.with_locale(:id) {
		event_type.name = id_name
		event_type.short_description = id_desc
		event_type.save!
	}

	puts "Event type: #{event_type.name}"
	event_type
end

upsert_event_type!(
	"Weddings",
	id_name: "Pernikahan",
	en_desc: "Say \"I do\" against a backdrop of manicured greens and ocean breeze. Our team crafts bespoke wedding experiences from intimate ceremonies to grand receptions.",
	id_desc: "Ucapkan \"Saya bersedia\" dengan latar hamparan hijau dan angin laut. Tim kami merancang pengalaman pernikahan khusus, dari upacara intim hingga resepsi megah.",
	image: "beach_club.png",
	position: 1
)

upsert_event_type!(
	"Corporate Events",
	id_name: "Acara Korporat",
	en_desc: "Impress clients and reward teams with golf days, tournaments, conferences and team-building sessions supported by full-service catering and event planning.",
	id_desc: "Kesankan klien dan apresiasi tim Anda dengan golf day, turnamen, konferensi, dan sesi team-building yang didukung layanan katering dan perencanaan acara penuh.",
	image: "banners/banner-events.png",
	position: 2
)

upsert_event_type!(
	"Private Celebrations",
	id_name: "Perayaan Pribadi",
	en_desc: "Birthdays, anniversaries and milestone gatherings — celebrate in style with flexible venues, curated menus and a setting your guests will never forget.",
	id_desc: "Ulang tahun, hari jadi, dan momen penting lainnya — rayakan dengan gaya di tempat yang fleksibel, menu pilihan, dan suasana yang tak terlupakan bagi tamu Anda.",
	image: "resto/mezzaluna.png",
	position: 3
)
