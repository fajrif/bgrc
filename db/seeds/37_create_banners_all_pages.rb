# Create Banners for All Pages
Banner.delete_all

banner = Banner.new(title: "Welcome to Bali Golf and Racket Club, where tropical paradise meets world-class sporting facilities.", description: "Whether you're a beginner, enthusiast, or seasoned pro, our exceptional golf course and top-tier tennis facilities in historic Nusa Dua offer an unforgettable experience for all ages and skill levels.")

banner.image.attach(io: Rails.root.join("vendor/assets/images/banners/banner-homepage.png").open, filename: "banner-homepage.png")
banner.banner_section = @bs1
Mobility.with_locale(:id) {
	banner.title = "Selamat datang di Bali Golf and Racket Club, tempat surga tropis bertemu dengan fasilitas olahraga kelas dunia."
	banner.description = "Baik Anda seorang pemula, penggemar, atau profesional berpengalaman, lapangan golf kami yang luar biasa dan fasilitas tenis tingkat atas di Nusa Dua yang bersejarah menawarkan pengalaman yang tak terlupakan untuk semua usia dan tingkat keterampilan."
}
banner.save
puts "Create Banner: #{banner.title}"
