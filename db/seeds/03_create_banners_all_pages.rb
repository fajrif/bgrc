# Create Banners for All Pages
Banner.delete_all

# Banner HomePage
banner = Banner.new(title: "Welcome to Bali Beach Country Club, where tropical paradise meets world-class sporting facilities.", description: "Whether you're a beginner, enthusiast, or seasoned pro, our exceptional golf course and top-tier tennis facilities in historic Nusa Dua offer an unforgettable experience for all ages and skill levels.")
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs1
Mobility.with_locale(:id) {
	banner.title = "Selamat datang di Bali Beach Country Club, tempat surga tropis bertemu dengan fasilitas olahraga kelas dunia."
	banner.description = "Baik Anda seorang pemula, penggemar, atau profesional berpengalaman, lapangan golf kami yang luar biasa dan fasilitas tenis tingkat atas di Nusa Dua yang bersejarah menawarkan pengalaman yang tak terlupakan untuk semua usia dan tingkat keterampilan."
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner About
banner = Banner.new(title: "About", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs2
Mobility.with_locale(:id) {
	banner.title = "Tentang Kami"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Contact
banner = Banner.new(title: "Contact", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs3
Mobility.with_locale(:id) {
	banner.title = "Kontak"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Facilities
banner = Banner.new(title: "Facilities", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs4
Mobility.with_locale(:id) {
	banner.title = "Fasilitas"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Sports
banner = Banner.new(title: "Sports", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs5
Mobility.with_locale(:id) {
	banner.title = "Olahraga"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Events
banner = Banner.new(title: "Events", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs6
Mobility.with_locale(:id) {
	banner.title = "Acara Kegiatan"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Promos
banner = Banner.new(title: "Promotion", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs7
Mobility.with_locale(:id) {
	banner.title = "Promosi"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Articles
banner = Banner.new(title: "Blog", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs8
Mobility.with_locale(:id) {
	banner.title = "Blog"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"

# Banner Packages
banner = Banner.new(title: "Packages", description: FFaker::Lorem.paragraphs.join(" "))
banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-sample.png").open, filename: "banner-sample.png")
banner.banner_section = @bs9
Mobility.with_locale(:id) {
	banner.title = "Paket"
	banner.description = FFaker::Lorem.paragraphs.join(" ")
}
banner.save
puts "Create Banner: #{banner.title}"
