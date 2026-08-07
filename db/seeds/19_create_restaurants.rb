puts "create restaurants"

RESTAURANT_IMAGES = Rails.root.join("vendor/assets/images/resto")
BANNER_IMAGES     = Rails.root.join("vendor/assets/images/restaurant")

def upsert_restaurant!(en_name, id_name:, image:, position:,
												en_short:, id_short:, en_banner:, id_banner:,
												en_desc:, id_desc:, en_desc1:, id_desc1:, en_desc2:, id_desc2:)
	restaurant = Restaurant.find_by("name @> ?", { en: en_name }.to_json) || Restaurant.new
	restaurant.name = en_name
	restaurant.short_description = en_short
	restaurant.banner_description = en_banner
	restaurant.description = en_desc
	restaurant.description1 = en_desc1
	restaurant.description2 = en_desc2
	restaurant.position = position

	restaurant.banner.attach(io: BANNER_IMAGES.join("banner-1.png").open, filename: "banner-1.png") unless restaurant.banner.attached?
	restaurant.middle_banner.attach(io: BANNER_IMAGES.join("banner-2.png").open, filename: "banner-2.png") unless restaurant.middle_banner.attached?
	restaurant.image.attach(io: RESTAURANT_IMAGES.join(image).open, filename: image) unless restaurant.image.attached?

	restaurant.save!

	Mobility.with_locale(:id) do
		restaurant.name = id_name
		restaurant.short_description = id_short
		restaurant.banner_description = id_banner
		restaurant.description = id_desc
		restaurant.description1 = id_desc1
		restaurant.description2 = id_desc2
		restaurant.save!
	end

	puts "Restaurant: #{restaurant.name}"
	restaurant
end

def upsert_menu!(restaurant, en_name, id_name:, en_desc:, id_desc:, image:, position:)
	menu = restaurant.menus.find_by("name @> ?", { en: en_name }.to_json) || Menu.new
	menu.restaurant = restaurant
	menu.position = position
	menu.name = en_name
	menu.short_description = en_desc
	menu.image.attach(io: MENU_IMAGES.join(image).open, filename: image) unless menu.image.attached?
	menu.save!

	Mobility.with_locale(:id) do
		menu.name = id_name
		menu.short_description = id_desc
		menu.save!
	end

	puts "Menu: #{menu.name} (#{restaurant.en_name})"
	menu
end

MENU_IMAGES = Rails.root.join("vendor/assets/images/restaurant")

the_paddock = upsert_restaurant!(
	"The Paddock", id_name: "The Paddock", image: "the_paddock.png", position: 1,
	en_short: "All-day dining with a garden view, from breakfast plates to sundowner cocktails.",
	id_short: "Restoran sepanjang hari dengan pemandangan taman, dari sarapan hingga koktail sore.",
	en_banner: "Championship views, all-day plates, and cocktails as the sun goes down.",
	id_banner: "Pemandangan lapangan, hidangan sepanjang hari, dan koktail saat matahari terbenam.",
	en_desc: "The Paddock is where the club comes to eat between rounds and matches — an all-day menu that begins with breakfast plates in the early morning and moves through to shared platters and sundowner cocktails by evening, all served on a terrace that looks straight out over the greens. It's the kind of place members drift in and out of throughout the day, whether that's a quick coffee before a tee time or a long, unhurried dinner once the courts have gone quiet for the night.",
	id_desc: "The Paddock adalah tempat klub bersantap di antara ronde dan pertandingan — menu sepanjang hari yang dimulai dengan sarapan di pagi hari dan berlanjut hingga hidangan berbagi serta koktail sore, semuanya disajikan di teras dengan pemandangan langsung ke lapangan. Ini tempat anggota singgah sepanjang hari, entah untuk secangkir kopi sebelum tee time atau makan malam santai setelah lapangan mulai sepi di malam hari.",
	en_desc1: "The kitchen leans eclectic rather than fixed to one cuisine, drawing on Asian, Mediterranean and classic Western influences so there is always something for a table split between a light lunch and a proper sit-down dinner. Dishes are designed to be shared as easily as they are ordered individually, and the wine and cocktail list has been built to work across the whole span of the menu. Bookings are recommended on weekends, when the terrace fills quickly with members coming straight off the course.\n\nService runs from early morning through to last orders in the evening, and a dedicated bar menu keeps drinks and light bites available even outside the kitchen's main hours. Whether you're after a full breakfast before your round, a working lunch with colleagues, or cocktails as the sun sets over the eighteenth green, The Paddock is built to move with however your day at the club unfolds.",
	id_desc1: "Dapur kami tidak terpaku pada satu jenis masakan, memadukan pengaruh Asia, Mediterania, dan Barat klasik sehingga selalu ada pilihan untuk meja yang terbagi antara makan siang ringan dan makan malam yang lebih lengkap. Hidangan dirancang untuk mudah dibagi maupun dipesan sendiri, dan daftar anggur serta koktail disusun agar cocok dengan seluruh menu. Reservasi disarankan pada akhir pekan, saat teras cepat terisi oleh anggota yang baru selesai bermain.\n\nLayanan berlangsung dari pagi hari hingga pesanan terakhir malam hari, dengan menu bar yang tetap tersedia di luar jam dapur utama untuk minuman dan camilan ringan. Baik Anda mencari sarapan lengkap sebelum bermain, makan siang santai bersama rekan, atau koktail saat matahari terbenam di lubang delapan belas, The Paddock dirancang mengikuti ritme hari Anda di klub.",
	en_desc2: "Expect a relaxed, unhurried pace here — tables are set with an open view of the course, service moves at your speed rather than the kitchen's, and nobody will rush you off a table once the plates are cleared. The wine and cocktail list is built to carry a table comfortably from lunch straight through to sundown, with lighter pours for the afternoon and something a little more serious once the light starts to fade over the fairways. It's a room built for lingering, not just eating.",
	id_desc2: "Nikmati suasana santai tanpa terburu-buru di sini — meja menghadap langsung ke lapangan, pelayanan mengikuti ritme Anda bukan ritme dapur, dan tidak ada yang akan meminta Anda beranjak setelah piring dibereskan. Daftar anggur dan koktail dirancang untuk menemani meja Anda dengan nyaman dari makan siang hingga senja, dengan pilihan yang lebih ringan di siang hari dan yang lebih berkarakter saat cahaya mulai meredup di atas lapangan. Ruangan ini dibuat untuk berlama-lama, bukan sekadar makan."
)

kazumi = upsert_restaurant!(
	"Kazumi Azayaka", id_name: "Kazumi Azayaka", image: "kazumi.png", position: 2,
	en_short: "Japanese small plates and izakaya-style sharing, best enjoyed as the sun goes down.",
	id_short: "Hidangan kecil Jepang bergaya izakaya untuk dinikmati bersama, paling nikmat saat senja.",
	en_banner: "Japanese small plates, sharing plates and cocktails in an izakaya atmosphere.",
	id_banner: "Hidangan kecil Jepang dan koktail dalam suasana izakaya.",
	en_desc: "Kazumi Azayaka serves Japanese small plates in the izakaya tradition — built for sharing across the table rather than arriving as one dish per person, with a cocktail list of sake, shochu and classic Japanese highballs designed to match. It's a menu meant to be worked through slowly over the course of an evening, plate by plate, rather than ordered all at once, and the open kitchen means you can watch much of it being cooked right in front of you as the night goes on.",
	id_desc: "Kazumi Azayaka menyajikan hidangan kecil Jepang bergaya izakaya — dirancang untuk dinikmati bersama di meja, bukan satu hidangan per orang, dengan daftar koktail sake, shochu, dan highball khas Jepang yang serasi. Menu ini dirancang untuk dinikmati perlahan sepanjang malam, sedikit demi sedikit, bukan dipesan sekaligus, dan dapur terbuka memungkinkan Anda menyaksikan sebagian besar proses memasaknya langsung di depan mata.",
	en_desc1: "The room fills up quickest around sunset, when the terrace lighting comes on, the charcoal grill gets going properly, and the kitchen starts sending out its evening specials — usually whatever came in freshest that day. A quieter lunch service runs through the week for members passing between the courts who want something lighter, and the bar counter stays a good option for anyone eating solo or dropping in without much notice.\n\nReservations are taken for parties of four or more, particularly on weekend evenings when tables turn over quickly, but walk-ins are always welcome at the bar counter any night of the week. Staff are happy to build a tasting sequence for first-timers who aren't sure where to start, working through the menu's smaller plates before moving on to anything more substantial.",
	id_desc1: "Ruangan paling ramai saat matahari terbenam, ketika lampu teras menyala, panggangan arang mulai bekerja penuh, dan dapur mengeluarkan menu spesial malam — biasanya bahan paling segar hari itu. Layanan makan siang yang lebih tenang tersedia sepanjang minggu bagi anggota yang ingin hidangan lebih ringan, dan meja bar tetap menjadi pilihan baik bagi yang makan sendiri atau datang tanpa rencana.\n\nReservasi diterima untuk kelompok empat orang atau lebih, terutama pada malam akhir pekan saat meja cepat berganti, namun tamu tanpa reservasi selalu disambut di meja bar kapan pun. Staf dengan senang hati menyusun rangkaian pencicipan bagi tamu baru yang belum yakin harus mulai dari mana, dimulai dari hidangan kecil sebelum beralih ke yang lebih besar.",
	en_desc2: "Expect charcoal-grilled skewers straight off the robata, delicate sashimi cut to order, and a rotating list of sake and shochu cocktails that changes with the season and whatever the bar team is experimenting with that month. Portions are intentionally small, which makes it easy to keep ordering through the evening rather than committing to one dish — the kind of menu built for slow grazing over a long night with friends, not a quick meal between other plans.",
	id_desc2: "Nikmati sate panggang arang langsung dari robata, sashimi lembut yang diiris sesuai pesanan, serta daftar koktail sake dan shochu yang terus berganti mengikuti musim dan eksperimen tim bar setiap bulannya. Porsi sengaja dibuat kecil, sehingga mudah untuk terus memesan sepanjang malam alih-alih terpaku pada satu hidangan — menu yang cocok dinikmati perlahan sepanjang malam bersama teman, bukan makan cepat di sela rencana lain."
)

pit_lane = upsert_restaurant!(
	"Pit Lane Sportsbar", id_name: "Pit Lane Sportsbar", image: "pit_lane.png", position: 3,
	en_short: "Craft drinks and every big match on screen, steps from the racquet courts.",
	id_short: "Minuman kreasi dan siaran pertandingan besar, hanya beberapa langkah dari lapangan raket.",
	en_banner: "Craft beer, cocktails and every big match, right off the racquet courts.",
	id_banner: "Bir kreasi, koktail, dan siaran pertandingan besar, tepat di sebelah lapangan raket.",
	en_desc: "Pit Lane is the club's sports bar, positioned a short walk from the racquet courts so a match can move straight from the court to the table without much of a detour. Screens run across the entire room for every major fixture, and the menu has been built around food that travels well from the kitchen to a group already deep in conversation about the game they just finished — or the one still playing out on screen.",
	id_desc: "Pit Lane adalah sports bar klub, terletak tak jauh dari lapangan raket sehingga permainan bisa langsung berlanjut ke meja makan tanpa perlu berjalan jauh. Layar tersebar di seluruh ruangan untuk setiap pertandingan besar, dan menu dirancang agar mudah dinikmati oleh kelompok yang sedang asyik membahas pertandingan yang baru selesai — atau yang masih berlangsung di layar.",
	en_desc1: "Craft beer and cocktails are the clear focus of the drinks list, backed up by a rotating selection tied to whatever tournament happens to be on screen that particular week, whether that's a Grand Slam, a major golf championship or a weekend of club fixtures. The bar team keeps a running tally of what's popular and swaps things out often enough that regulars always find something new.\n\nNo bookings are required here — it runs entirely first-come, first-served, with the busiest stretches falling on weekend match days and evenings when a big fixture is being screened live. Large groups are welcome to push tables together, and staff are used to accommodating parties who show up straight off the court still in their kit.",
	id_desc1: "Bir kreasi dan koktail menjadi fokus utama daftar minuman, didukung pilihan yang terus berganti mengikuti turnamen yang sedang tayang minggu itu, entah itu Grand Slam, kejuaraan golf besar, atau jadwal pertandingan klub akhir pekan. Tim bar memantau minuman yang paling digemari dan sering mengganti pilihan agar pelanggan tetap menemukan sesuatu yang baru.\n\nTidak perlu reservasi di sini — sepenuhnya melayani siapa cepat dia dapat, dengan waktu tersibuk jatuh pada hari pertandingan akhir pekan dan malam saat pertandingan besar disiarkan langsung. Kelompok besar dipersilakan menggabungkan meja, dan staf terbiasa melayani tamu yang datang langsung dari lapangan, masih mengenakan pakaian olahraga.",
	en_desc2: "Sharing boards, wings and loaded fries dominate the menu, all built to keep a table fed comfortably through extra time without anyone having to leave their seat or miss a moment of the action on screen. Portions are generous and designed for passing around rather than plating individually, which suits the room's whole atmosphere — loud, sociable, and built entirely around watching sport together rather than a quiet sit-down meal.",
	id_desc2: "Papan hidangan berbagi, sayap ayam, dan kentang goreng menjadi andalan menu — semuanya dirancang agar meja tetap terisi sepanjang perpanjangan waktu tanpa perlu beranjak dari kursi atau melewatkan momen di layar. Porsi disajikan besar dan dirancang untuk dibagi, bukan disajikan per orang, sesuai dengan suasana ruangan — ramai, akrab, dan sepenuhnya dibangun untuk menonton pertandingan bersama, bukan makan malam yang tenang."
)

mezzaluna = upsert_restaurant!(
	"Mezzaluna", id_name: "Mezzaluna", image: "mezzaluna.png", position: 4,
	en_short: "Modern Italian in a quiet dining room, built for a proper sit-down evening.",
	id_short: "Hidangan Italia modern di ruang makan yang tenang, cocok untuk makan malam santai.",
	en_banner: "Modern Italian cooking and a curated wine list in a quiet dining room.",
	id_banner: "Masakan Italia modern dan daftar anggur pilihan di ruang makan yang tenang.",
	en_desc: "Mezzaluna is the club's dedicated dinner room — modern Italian cooking served at a noticeably slower pace than the rest of the club, in a dining room deliberately set apart from the sport and pool areas so the evening feels like a genuine escape. It's the venue members choose when they want an evening that feels like leaving the club entirely, even though it's only a short walk from the courts.",
	id_desc: "Mezzaluna adalah ruang makan malam khusus klub — masakan Italia modern yang disajikan dengan tempo jauh lebih santai dibanding area klub lainnya, di ruang makan yang sengaja dipisahkan dari area olahraga dan kolam renang agar malam terasa seperti pelarian sejati. Ini tempat pilihan anggota yang ingin merasakan malam seolah meninggalkan klub sepenuhnya, meski jaraknya hanya beberapa langkah dari lapangan.",
	en_desc1: "The menu changes seasonally around whatever the kitchen can source locally, built around house-made pasta rolled fresh each morning and a wine list chosen specifically to match each course rather than added as an afterthought. It suits a proper sit-down evening rather than a quick meal squeezed between activities, and the kitchen is happy to talk through pairings if you're unsure where to start.\n\nReservations are recommended for any evening, and particularly important for tables of six or more, since the room is intentionally kept small to preserve the quiet, unhurried atmosphere that makes Mezzaluna what it is. Private dining can also be arranged for special occasions with enough notice.",
	id_desc1: "Menu berganti musiman mengikuti bahan lokal yang tersedia, dibangun di sekitar pasta buatan sendiri yang digiling segar setiap pagi dan daftar anggur yang dipilih khusus untuk melengkapi setiap hidangan, bukan sekadar tambahan. Cocok untuk makan malam yang sesungguhnya, bukan makan cepat di antara aktivitas, dan dapur dengan senang hati membantu memilih padanan anggur bila Anda belum yakin harus mulai dari mana.\n\nReservasi disarankan untuk malam apa pun, dan sangat penting untuk meja enam orang atau lebih, karena ruangan ini sengaja dijaga tetap kecil untuk mempertahankan suasana tenang yang menjadi ciri khas Mezzaluna. Jamuan privat juga dapat diatur untuk acara khusus dengan pemberitahuan yang cukup.",
	en_desc2: "From hand-rolled pasta to a wood-fired secondi cooked over an open flame, every plate here is built for a table that genuinely wants to linger rather than move quickly through courses. The wine list runs from easy-drinking whites suited to a warm evening through to serious Italian reds for anyone looking to make a night of it, and staff are always happy to recommend a pairing for whatever you've ordered.",
	id_desc2: "Dari pasta buatan tangan hingga hidangan utama yang dipanggang di atas api terbuka, setiap piring di sini dirancang untuk meja yang benar-benar ingin berlama-lama, bukan bergegas melewati setiap hidangan. Daftar anggur mencakup pilihan putih yang ringan untuk malam yang hangat hingga merah Italia yang penuh karakter bagi yang ingin menikmati malam sepenuhnya, dan staf selalu siap merekomendasikan padanan untuk hidangan yang Anda pesan."
)

portobello = upsert_restaurant!(
	"Portobello", id_name: "Portobello", image: "portobello.png", position: 5,
	en_short: "A lively table for sharing plates, wine and late-night conversation.",
	id_short: "Meja yang hidup untuk hidangan berbagi, anggur, dan obrolan hingga larut malam.",
	en_banner: "Sharing plates, a deep wine list and the latest kitchen on property.",
	id_banner: "Hidangan berbagi, daftar anggur yang lengkap, dan dapur terbaru di area klub.",
	en_desc: "Portobello is the liveliest table at the club — small sharing plates, a genuinely deep wine list, and a room that stays open noticeably later than most of the others on property. It's built for evenings that don't have a fixed end time, where one round of plates turns into another and the conversation just keeps going long after other venues on the grounds have already closed their kitchens for the night and switched off the lights.",
	id_desc: "Portobello adalah meja paling hidup di klub — hidangan kecil untuk berbagi, daftar anggur yang benar-benar lengkap, dan ruangan yang buka jauh lebih larut dibanding sebagian besar area klub lainnya. Dibangun untuk malam yang tidak punya batas waktu, di mana satu putaran hidangan berlanjut ke putaran berikutnya dan obrolan terus mengalir lama setelah tempat lain di area klub sudah menutup dapurnya dan mematikan lampu.",
	en_desc1: "It works equally well for a casual dinner with a couple of plates and a glass of wine, or a much longer evening with the table constantly refilling as new dishes arrive. The bar carries on serving well after the kitchen has taken its last order, so the night doesn't have to end just because the food service has wound down.\n\nWalk-ins are always taken at the bar, while the dining room itself accepts reservations for groups up to eight people. Larger celebrations can be arranged with advance notice, and the team is happy to build a set sharing menu for bigger tables who would rather not order individually off the main menu.",
	id_desc1: "Cocok untuk makan malam santai dengan beberapa hidangan dan segelas anggur, atau malam yang jauh lebih panjang dengan meja yang terus terisi ulang seiring hidangan baru datang. Bar tetap melayani jauh setelah dapur menerima pesanan terakhirnya, sehingga malam tidak harus berakhir hanya karena layanan makanan sudah selesai.\n\nTamu tanpa reservasi selalu dilayani di bar, sementara ruang makan menerima reservasi untuk kelompok hingga delapan orang. Perayaan yang lebih besar dapat diatur dengan pemberitahuan lebih awal, dan tim dengan senang hati menyusun menu berbagi khusus bagi meja besar yang tidak ingin memesan satu per satu dari menu utama.",
	en_desc2: "Small plates keep arriving steadily through the night, designed to be ordered a few at a time and shared generously across the table rather than claimed by one person. Each dish is paired with whatever the sommelier happens to be pouring that particular evening, which changes often enough that regulars rarely get the exact same pairing twice — part of what keeps people coming back to the same table again and again.",
	id_desc2: "Hidangan kecil terus datang secara teratur sepanjang malam, dirancang untuk dipesan beberapa sekaligus dan dinikmati bersama di meja, bukan diklaim satu orang saja. Setiap hidangan dipadukan dengan anggur pilihan sommelier malam itu, yang cukup sering berganti sehingga pelanggan tetap jarang mendapat padanan yang sama persis dua kali — salah satu alasan mereka selalu ingin kembali lagi ke meja yang sama."
)

menu_items = [
	{ en: "Laksa", id_name: "Laksa", image: "laksa.png",
		en_desc: "Coconut curry noodle soup with prawns and a soft-boiled egg.",
		id_desc: "Sup mie kari santan dengan udang dan telur setengah matang." },
	{ en: "Egg Noodle Soup with Crispy Pork", id_name: "Sup Mie Telur dengan Babi Renyah", image: "yellow-noodles-cup-with-crispy-pork-slices-pork-meatballs-together-with-thai-food-style-noodles.png",
		en_desc: "Yellow egg noodles with crispy pork belly, pork meatballs and fresh herbs.",
		id_desc: "Mie telur kuning dengan perut babi renyah, bakso babi, dan rempah segar." },
	{ en: "Larb Moo with Sticky Rice", id_name: "Larb Moo dengan Nasi Ketan", image: "thai-food-with-spicy-minced-pork-serve-with-sticky-rice-fried-chicken.png",
		en_desc: "Spicy minced pork salad with herbs, lime and sticky rice on the side.",
		id_desc: "Salad babi cincang pedas dengan rempah, jeruk nipis, dan nasi ketan." },
	{ en: "Spicy Pork Chop Salad", id_name: "Salad Iga Babi Pedas", image: "spicy-pork-chops-black-cup-consisting-lemons-chili-side-dishes.png",
		en_desc: "Grilled pork chop sliced over a spicy herb salad with chili and lime.",
		id_desc: "Iga babi panggang diiris di atas salad rempah pedas dengan cabai dan jeruk nipis." }
]

[the_paddock, kazumi, pit_lane, mezzaluna, portobello].each do |restaurant|
	menu_items.each_with_index do |item, i|
		upsert_menu!(
			restaurant, item[:en], id_name: item[:id_name],
			en_desc: item[:en_desc], id_desc: item[:id_desc], image: item[:image], position: i + 1
		)
	end
end
