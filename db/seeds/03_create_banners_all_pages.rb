# Ensure Banners for All Pages
# Idempotent: only creates a banner for sections that don't already have one, never deletes.
# Safe to re-run on production — existing banners (including anything edited via admin) are
# left untouched; this only fills in banners that are missing (e.g. for a newly added section).
puts "ensure banners for all pages"

def lorem_paragraphs
  FFaker::Lorem.paragraphs.join(" ")
end

banners_data = [
  { section: "Home", image: "banner-home.png",
    title: "Welcome to Bali Beach Country Club, where tropical paradise meets world-class sporting facilities.",
    description: "Whether you're a beginner, enthusiast, or seasoned pro, our exceptional golf course and top-tier tennis facilities in historic Nusa Dua offer an unforgettable experience for all ages and skill levels.",
    title_id: "Selamat datang di Bali Beach Country Club, tempat surga tropis bertemu dengan fasilitas olahraga kelas dunia.",
    description_id: "Baik Anda seorang pemula, penggemar, atau profesional berpengalaman, lapangan golf kami yang luar biasa dan fasilitas tenis tingkat atas di Nusa Dua yang bersejarah menawarkan pengalaman yang tak terlupakan untuk semua usia dan tingkat keterampilan." },

  { section: "About", image: "banner-about.png", title: "About", description: lorem_paragraphs, title_id: "Tentang Kami", description_id: lorem_paragraphs },
  { section: "Contact", image: "banner-contact.png", title: "Contact", description: lorem_paragraphs, title_id: "Kontak", description_id: lorem_paragraphs },
  { section: "Facilities", image: "banner-facilities.png", title: "Facilities", description: lorem_paragraphs, title_id: "Fasilitas", description_id: lorem_paragraphs },
  { section: "Sports", image: "banner-sports.png", title: "Sports", description: lorem_paragraphs, title_id: "Olahraga", description_id: lorem_paragraphs },
  { section: "Events", image: "banner-events.png", title: "Events", description: lorem_paragraphs, title_id: "Acara Kegiatan", description_id: lorem_paragraphs },
  { section: "Promos", image: "banner-promo.png", title: "Promotion", description: lorem_paragraphs, title_id: "Promosi", description_id: lorem_paragraphs },
  { section: "Articles", image: "banner-blogs.png", title: "Blog", description: lorem_paragraphs, title_id: "Blog", description_id: lorem_paragraphs },
  { section: "Packages", image: "banner-packages.png", title: "Packages", description: lorem_paragraphs, title_id: "Paket", description_id: lorem_paragraphs },
  { section: "Golf", image: "banner-golf.png", title: "Golf", description: lorem_paragraphs, title_id: "Golf", description_id: lorem_paragraphs },
  { section: "Tennis", image: "banner-tennis.png", title: "Tennis", description: lorem_paragraphs, title_id: "Tennis", description_id: lorem_paragraphs },
  { section: "Padel", image: "banner-padel.png", title: "Padel", description: lorem_paragraphs, title_id: "Padel", description_id: lorem_paragraphs },
  { section: "Pickleball", image: "banner-pickleball.png", title: "Pickleball", description: lorem_paragraphs, title_id: "Pickleball", description_id: lorem_paragraphs },

  { section: "FAQ", image: "banner-contact.png",
    title: "FAQ", description: "Answers to the most common questions about booking, payments, membership and more at Bali Beach Country Club.",
    title_id: "FAQ", description_id: "Jawaban atas pertanyaan yang paling sering diajukan seputar pemesanan, pembayaran, keanggotaan, dan lainnya di Bali Beach Country Club." },

  { section: "Gallery", image: "restaurant.png", dir: "facilities",
    title: "Gallery", description: "A look at life around Bali Beach Country Club — our courts, courses, facilities and events.",
    title_id: "Galeri", description_id: "Sekilas kehidupan di Bali Beach Country Club — lapangan, fasilitas, dan acara kami." },

  { section: "Our Team", image: "restaurant.png", dir: "facilities",
    title: "Our Team", description: "Meet the people behind Bali Beach Country Club — from the clubhouse kitchen to the practice courts.",
    title_id: "Tim Kami", description_id: "Kenali orang-orang di balik Bali Beach Country Club — mulai dari dapur klub hingga lapangan latihan." },

  { section: "MITS Academy", image: "banner-tennis.png",
    title: "MITS Academy", description: "Our coaching partner for tennis, padel and pickleball — elite programs for every age and ambition.",
    title_id: "MITS Academy", description_id: "Mitra pelatihan kami untuk tenis, padel, dan pickleball — program unggulan untuk segala usia dan ambisi." },

  { section: "Disclaimer", image: "banner-golf.png",
    title: "Disclaimer", description: "Please read this disclaimer carefully before using the Bali Beach Country Club website.",
    title_id: "Disclaimer", description_id: "Harap baca disclaimer ini dengan saksama sebelum menggunakan situs web Bali Beach Country Club." },

  { section: "Privacy Policy", image: "banner-golf.png",
    title: "Privacy Policy", description: "How Bali Beach Country Club collects, uses and protects your personal information.",
    title_id: "Kebijakan Privasi", description_id: "Bagaimana Bali Beach Country Club mengumpulkan, menggunakan, dan melindungi informasi pribadi Anda." },

  { section: "Terms & Conditions", image: "banner-golf.png",
    title: "Terms & Conditions", description: "The terms, cancellation and refund policies that apply to bookings at Bali Beach Country Club.",
    title_id: "Syarat & Ketentuan", description_id: "Syarat, kebijakan pembatalan, dan pengembalian dana yang berlaku untuk pemesanan di Bali Beach Country Club." },

  { section: "Club Life", image: "banner-padel.png",
    title: "Club Life", description: "Golf, racquet sports, the beach club, fitness and wellness — everything the club opens up to you.",
    title_id: "Club Life", description_id: "Golf, olahraga raket, beach club, kebugaran, dan wellness — semua yang klub tawarkan untuk Anda." },

  { section: "Highlights", image: "banner-events.png",
    title: "BBCC Highlights", description: "Socials, clinics, tournaments and the regular fixtures that make up the club calendar.",
    title_id: "BBCC Highlights", description_id: "Acara sosial, klinik, turnamen, dan agenda rutin yang mengisi kalender klub." },
]

banners_data.each do |data|
  section = BannerSection.find_or_create_by!(name: data[:section])
  banner = Banner.find_or_initialize_by(banner_section: section)

  if banner.persisted?
    puts "Banner already exists for #{section.name}, skipping"
    next
  end

  dir = data[:dir] || "banners"
  banner.title = data[:title]
  banner.description = data[:description]
  banner.image.attach(io: Rails.root.join("vendor/assets/images/#{dir}/#{data[:image]}").open, filename: data[:image])
  Mobility.with_locale(:id) {
    banner.title = data[:title_id]
    banner.description = data[:description_id]
  }
  banner.save!
  puts "Create Banner: #{banner.title}"
end
