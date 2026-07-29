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

puts "Highlights: #{Highlight.count}"
