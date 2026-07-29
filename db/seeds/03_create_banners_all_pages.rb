# Create Banners for All Pages
Banner.delete_all

# Banner HomePage
banner = Banner.new(title: "Welcome to Bali Beach Country Club, where tropical paradise meets world-class sporting facilities.", description: "Whether you're a beginner, enthusiast, or seasoned pro, our exceptional golf course and top-tier tennis facilities in historic Nusa Dua offer an unforgettable experience for all ages and skill levels.")
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-home.png").open, filename: "banner-home.png")
banner.banner_section = @bs1
Mobility.with_locale(:id) {
	banner.title = "Selamat datang di Bali Beach Country Club, tempat surga tropis bertemu dengan fasilitas olahraga kelas dunia."
	banner.description = "Baik Anda seorang pemula, penggemar, atau profesional berpengalaman, lapangan golf kami yang luar biasa dan fasilitas tenis tingkat atas di Nusa Dua yang bersejarah menawarkan pengalaman yang tak terlupakan untuk semua usia dan tingkat keterampilan."
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner About
banner = Banner.new(title: "About", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-about.png").open, filename: "banner-about.png")
banner.banner_section = @bs2
Mobility.with_locale(:id) {
	banner.title = "Tentang Kami"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Contact
banner = Banner.new(title: "Contact", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-contact.png").open, filename: "banner-contact.png")
banner.banner_section = @bs3
Mobility.with_locale(:id) {
	banner.title = "Kontak"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Facilities
banner = Banner.new(title: "Facilities", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-facilities.png").open, filename: "banner-facilities.png")
banner.banner_section = @bs4
Mobility.with_locale(:id) {
	banner.title = "Fasilitas"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Sports
banner = Banner.new(title: "Sports", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sports.png").open, filename: "banner-sports.png")
banner.banner_section = @bs5
Mobility.with_locale(:id) {
	banner.title = "Olahraga"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Events
banner = Banner.new(title: "Events", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-events.png").open, filename: "banner-events.png")
banner.banner_section = @bs6
Mobility.with_locale(:id) {
	banner.title = "Acara Kegiatan"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Promos
banner = Banner.new(title: "Promotion", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-promo.png").open, filename: "banner-promo.png")
banner.banner_section = @bs7
Mobility.with_locale(:id) {
	banner.title = "Promosi"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Articles
banner = Banner.new(title: "Blog", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-blogs.png").open, filename: "banner-blogs.png")
banner.banner_section = @bs8
Mobility.with_locale(:id) {
	banner.title = "Blog"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Packages
banner = Banner.new(title: "Packages", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-packages.png").open, filename: "banner-packages.png")
banner.banner_section = @bs9
Mobility.with_locale(:id) {
	banner.title = "Paket"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Golf
banner = Banner.new(title: "Golf", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-golf.png").open, filename: "banner-golf.png")
banner.banner_section = @bs10
Mobility.with_locale(:id) {
	banner.title = "Golf"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Tennis
banner = Banner.new(title: "Tennis", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-tennis.png").open, filename: "banner-tennis.png")
banner.banner_section = @bs11
Mobility.with_locale(:id) {
	banner.title = "Tennis"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Padel
banner = Banner.new(title: "Padel", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-padel.png").open, filename: "banner-padel.png")
banner.banner_section = @bs12
Mobility.with_locale(:id) {
	banner.title = "Padel"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Pickleball
banner = Banner.new(title: "Pickleball", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-pickleball.png").open, filename: "banner-pickleball.png")
banner.banner_section = @bs13
Mobility.with_locale(:id) {
	banner.title = "Pickleball"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner FAQ
banner = Banner.new(title: "FAQ", description: "Answers to the most common questions about booking, payments, membership and more at Bali Beach Country Club.")
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-contact.png").open, filename: "banner-contact.png")
banner.banner_section = @bs14
Mobility.with_locale(:id) {
	banner.title = "FAQ"
	banner.description = "Jawaban atas pertanyaan yang paling sering diajukan seputar pemesanan, pembayaran, keanggotaan, dan lainnya di Bali Beach Country Club."
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Gallery
banner = Banner.new(title: "Gallery", description: "A look at life around Bali Beach Country Club — our courts, courses, facilities and events.")
banner.image.attach(io: Rails.root.join("vendor/assets/images/facilities/restaurant.png").open, filename: "restaurant.png")
banner.banner_section = @bs15
Mobility.with_locale(:id) {
	banner.title = "Galeri"
	banner.description = "Sekilas kehidupan di Bali Beach Country Club — lapangan, fasilitas, dan acara kami."
}
banner.save
puts "Create Banner: #{banner.title}"
