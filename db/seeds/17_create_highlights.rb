# Highlights — the club calendar entries that used to be hardcoded in
# shared/_bbcc_highlights and home/_highlights. Seeded here so the client can
# edit them in the admin panel. Safe to re-run.
puts "create highlights"

HIGHLIGHT_IMAGES = Rails.root.join("vendor/assets/images")

def highlight!(en_title, attrs:, id:, image:, category: nil)
	record = Highlight.find_by("title @> ?", { en: en_title }.to_json) || Highlight.new
	record.assign_attributes(attrs.merge(title: en_title, category: category))
	if image.present? && !record.image.attached?
		record.image.attach(io: HIGHLIGHT_IMAGES.join(image).open, filename: File.basename(image))
	end
	record.save!

	Mobility.with_locale(:id) do
		record.title = id[:title]
		record.short_description = id[:short_description]
		record.content = id[:content]
		record.save!
	end

	puts "Create Highlight: #{record.title}"
	record
end

cat_golf       = Category.find_by("name @> ?", { en: "Golf" }.to_json)
cat_tennis     = Category.find_by("name @> ?", { en: "Tennis" }.to_json)
cat_padel      = Category.find_by("name @> ?", { en: "Padel" }.to_json)
cat_pickleball = Category.find_by("name @> ?", { en: "Pickleball" }.to_json)

highlight!(
	"Sunset Golf Sessions",
	category: cat_golf,
	attrs: {
		status: 1, position: 1, tags: "Weekly",
		short_description: "Twilight tee times with course lighting, ideal for members who like to finish the round as the sun goes down.",
		content: "<p>Sunset sessions are our late tee times, released daily alongside the rest of the sheet. Course lighting keeps the closing holes playable well past dusk, so a nine hole round after work finishes comfortably.</p><p>Carts, buggies and caddies can all be added when you book, and the restaurant stays open afterwards.</p>"
	},
	id: {
		title: "Sesi Golf Sunset",
		short_description: "Tee time senja dengan pencahayaan lapangan, cocok untuk anggota yang ingin menyelesaikan permainan saat matahari terbenam.",
		content: "<p>Sesi sunset adalah tee time sore kami, dibuka setiap hari bersama jadwal lainnya. Pencahayaan lapangan menjaga hole penutup tetap dapat dimainkan hingga lewat senja.</p><p>Cart, buggy, dan caddie dapat ditambahkan saat memesan, dan restoran tetap buka setelahnya.</p>"
	},
	image: "sports/golf/gallery-4.png"
)

highlight!(
	"Weekend Pickleball Socials",
	category: cat_pickleball,
	attrs: {
		status: 1, position: 2, tags: "Weekends",
		short_description: "Open-play socials every weekend — a relaxed way for members and guests to meet other players on the court.",
		content: "<p>Open play, rotating partners, no fixed teams. Turn up with a paddle — or borrow one from the pro shop — and you will be on court within a few minutes.</p><p>All levels are welcome; the short court and light paddle make it the easiest of our racquet sports to pick up cold.</p>"
	},
	id: {
		title: "Pickleball Sosial Akhir Pekan",
		short_description: "Permainan terbuka setiap akhir pekan — cara santai bagi anggota dan tamu untuk bertemu pemain lain di lapangan.",
		content: "<p>Permainan terbuka dengan pasangan bergantian, tanpa tim tetap. Datang dengan raket Anda — atau pinjam di pro shop — dan Anda akan bermain dalam beberapa menit.</p><p>Semua level diterima; lapangan pendek dan raket ringan membuatnya paling mudah dipelajari.</p>"
	},
	image: "sports/pickleball/gallery-3.png"
)

highlight!(
	"Junior Tennis Clinics",
	category: cat_tennis,
	attrs: {
		status: 1, position: 3, tags: "Weekly",
		short_description: "MITS Academy-led clinics building fundamentals for young players, held weekly on our tennis courts.",
		content: "<p>Our junior clinics are run by MITS Academy coaches and grouped by age and level, so beginners are never on court with players well ahead of them.</p><p>Sessions cover grip, footwork and rally consistency before moving on to match play. Places are limited each week — book through the class listings.</p>"
	},
	id: {
		title: "Klinik Tenis Junior",
		short_description: "Klinik yang dipimpin pelatih MITS Academy untuk membangun dasar permainan pemain muda, diadakan setiap minggu.",
		content: "<p>Klinik junior kami dijalankan oleh pelatih MITS Academy dan dikelompokkan berdasarkan usia dan level.</p><p>Sesi mencakup pegangan, footwork, dan konsistensi reli sebelum masuk ke permainan pertandingan. Tempat terbatas setiap minggu.</p>"
	},
	image: "sports/tennis/gallery-5.png"
)

highlight!(
	"Ladies' Night",
	category: cat_padel,
	attrs: {
		status: 1, position: 4, tags: "Fridays",
		short_description: "A weekly Friday padel class for women, from complete beginners through to regular players.",
		content: "<p>Ladies' night runs every Friday afternoon on the padel courts. It is a scheduled group class rather than open play, so numbers are capped and everyone gets court time.</p><p>Padel is the quickest of our racquet sports to learn — the walls keep the ball alive and rallies last, which makes a first session genuinely playable.</p>"
	},
	id: {
		title: "Ladies' Night",
		short_description: "Kelas padel mingguan setiap Jumat untuk perempuan, dari pemula hingga pemain reguler.",
		content: "<p>Ladies' night berlangsung setiap Jumat sore di lapangan padel. Ini adalah kelas grup terjadwal, sehingga jumlah peserta dibatasi dan semua orang mendapat waktu bermain.</p><p>Padel adalah olahraga raket kami yang paling cepat dipelajari.</p>"
	},
	image: "images/image-6.png"
)

highlight!(
	"Weekend Tournaments",
	category: cat_tennis,
	attrs: {
		status: 1, position: 5, tags: "Monthly",
		short_description: "Club tournaments across tennis, padel and pickleball, drawn by level so every bracket is competitive.",
		content: "<p>Tournaments run monthly and rotate between tennis, padel and pickleball. Draws are seeded by level rather than open, so first-timers are not put straight against the club's strongest players.</p><p>Entry is through the front desk and closes the week before each event.</p>"
	},
	id: {
		title: "Turnamen Akhir Pekan",
		short_description: "Turnamen klub untuk tenis, padel, dan pickleball, dibagi berdasarkan level agar setiap babak kompetitif.",
		content: "<p>Turnamen diadakan setiap bulan dan bergantian antara tenis, padel, dan pickleball. Undian dibuat berdasarkan level, bukan terbuka.</p><p>Pendaftaran melalui front desk dan ditutup satu minggu sebelum acara.</p>"
	},
	image: "images/image-3.png"
)

highlight!(
	"Sunrise Yoga on the Lawn",
	attrs: {
		status: 1, position: 6, tags: "Daily",
		short_description: "Early morning yoga on the club lawn, led by our resident instructors before the day heats up.",
		content: "<p>Mats go down at first light on the lawn overlooking the course, with sessions paced for a calm, easy start to the day rather than a hard workout.</p><p>Open to all levels — mats are provided, and the session wraps in time for breakfast at the restaurant.</p>"
	},
	id: {
		title: "Yoga Pagi di Lapangan Rumput",
		short_description: "Yoga pagi hari di lapangan rumput klub, dipandu instruktur tetap kami sebelum hari mulai terik.",
		content: "<p>Matras digelar saat fajar di lapangan rumput menghadap lapangan golf, dengan sesi yang dirancang untuk awal hari yang tenang.</p><p>Terbuka untuk semua level — matras disediakan, dan sesi selesai tepat waktu untuk sarapan di restoran.</p>"
	},
	image: "facilities/yoga.png"
)

highlight!(
	"Beach Club Sunset Social",
	attrs: {
		status: 1, position: 7, tags: "Fridays",
		short_description: "A relaxed Friday evening gathering at the Beach Club, with live music and a casual bar menu as the sun goes down.",
		content: "<p>Every Friday the Beach Club opens up for an evening social — loungers by the water, a casual bar menu and light live music as the sky turns.</p><p>No booking required for members; just walk in after your last game or round and stay for the evening.</p>"
	},
	id: {
		title: "Sosial Sunset di Beach Club",
		short_description: "Kumpul santai Jumat sore di Beach Club, dengan musik live dan menu bar kasual saat matahari terbenam.",
		content: "<p>Setiap Jumat, Beach Club dibuka untuk sosial malam — kursi santai di tepi air, menu bar kasual, dan musik live ringan saat langit berubah warna.</p><p>Tidak perlu reservasi untuk anggota; cukup datang setelah permainan atau putaran terakhir Anda dan nikmati malamnya.</p>"
	},
	image: "beach_club.png"
)

highlight!(
	"Junior Golf Academy",
	category: cat_golf,
	attrs: {
		status: 1, position: 8, tags: "Weekly",
		short_description: "Weekly coaching for young golfers, from first swings on the range through to supervised rounds on the course.",
		content: "<p>The junior academy runs weekly sessions grouped by age and experience, starting on the range before progressing to supervised holes on the course.</p><p>Clubs are available to borrow for beginners, and places are booked through the coaching schedule.</p>"
	},
	id: {
		title: "Akademi Golf Junior",
		short_description: "Pelatihan mingguan untuk pegolf muda, mulai dari ayunan pertama di driving range hingga putaran di lapangan dengan pengawasan.",
		content: "<p>Akademi junior mengadakan sesi mingguan yang dikelompokkan berdasarkan usia dan pengalaman, dimulai dari driving range sebelum lanjut ke hole di lapangan dengan pengawasan.</p><p>Stik golf tersedia untuk dipinjam bagi pemula, dan tempat dipesan melalui jadwal pelatihan.</p>"
	},
	image: "sports/golf/gallery-2.png"
)

highlight!(
	"Members' Padel Ladder",
	category: cat_padel,
	attrs: {
		status: 1, position: 9, tags: "Monthly",
		short_description: "A running monthly ladder for padel members — win to climb, with standings posted at the pro shop.",
		content: "<p>The ladder runs continuously through the month; results are logged after each match and standings are posted at the pro shop and updated online.</p><p>Matches are arranged directly between members within a rung of each other, so games stay competitive without needing to schedule a full bracket.</p>"
	},
	id: {
		title: "Tangga Peringkat Padel Anggota",
		short_description: "Kompetisi tangga peringkat padel bulanan untuk anggota — menang untuk naik peringkat, hasil ditempel di pro shop.",
		content: "<p>Tangga peringkat berjalan sepanjang bulan; hasil dicatat setelah setiap pertandingan dan peringkat ditempel di pro shop serta diperbarui secara online.</p><p>Pertandingan diatur langsung antar anggota pada peringkat yang berdekatan, sehingga permainan tetap kompetitif tanpa perlu menjadwalkan bagan penuh.</p>"
	},
	image: "sports/padel/gallery-2.png"
)

highlight!(
	"Spa Recovery Weekends",
	attrs: {
		status: 1, position: 10, tags: "Weekends",
		short_description: "Weekend recovery packages pairing spa treatments with our recovery center facilities for members after a heavy week of play.",
		content: "<p>Recovery weekends pair a spa treatment with time in the recovery center — ice bath, sauna and stretch area — booked as a single slot rather than separately.</p><p>Popular after tournament weekends; book a day ahead through the spa desk as slots are limited.</p>"
	},
	id: {
		title: "Akhir Pekan Pemulihan Spa",
		short_description: "Paket pemulihan akhir pekan yang memadukan perawatan spa dengan fasilitas recovery center untuk anggota setelah minggu bermain yang berat.",
		content: "<p>Akhir pekan pemulihan memadukan perawatan spa dengan waktu di recovery center — ice bath, sauna, dan area peregangan — dipesan sebagai satu slot, bukan terpisah.</p><p>Populer setelah akhir pekan turnamen; pesan sehari sebelumnya melalui meja spa karena slot terbatas.</p>"
	},
	image: "downloads/treatment-2.png"
)

puts "Highlights: #{Highlight.count}"
